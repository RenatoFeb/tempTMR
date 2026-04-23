import tkinter as tk
from tkinter import ttk
import threading
import time
from collections import deque

try:
    import serial
    import serial.tools.list_ports
    SERIAL_AVAILABLE = True
except ImportError:
    SERIAL_AVAILABLE = False

# ─── Colour palette ────────────────────────────────────────────────────────────
BG      = "#0d1117"
PANEL   = "#161b22"
BORDER  = "#30363d"
ACCENT  = "#00e5ff"
ACCENT2 = "#ff6b35"
GREEN   = "#39d353"
RED     = "#f85149"
YELLOW  = "#e3b341"
TEXT    = "#e6edf3"
SUBTEXT = "#8b949e"
DIMMED  = "#3d4450"

UPDATE_MS   = 200       # GUI refresh interval (ms)
BAUD        = 115_200
PKT_LEN_OLD = 5         # legacy: [AA][temp][enc_pos][status][55]
PKT_LEN_NEW = 6         # new:    [AA][temp][enc_pos][status][xor][55]
SOF         = 0xAA
EOF_BYTE    = 0x55

# enc_pos_rf from Encoder.v:
#   assign enc_pos = (abs_position >= 200) ? 8'd200 : abs_position[7:0];
# pkt[2] is already a direct absolute position 0-200. No accumulation in Python.
ENC_MAX = 200


# ══════════════════════════════════════════════════════════════════════════════
#  Real UART interface
# ══════════════════════════════════════════════════════════════════════════════
class SerialFPGA:

    def __init__(self):
        self._ser         = None
        self._buf         = bytearray()
        self._lock        = threading.Lock()
        self._latest      = None
        self._connected   = False
        self._thread      = None
        self._stop_evt    = threading.Event()
        self._rx_count    = 0
        self._err_count   = 0
        self._raw_bytes   = 0
        self._last_rx_t   = 0.0

    # ── Connection management ───────────────────────────────────────────────
    def connect(self, port: str) -> bool:
        self.disconnect()
        if not SERIAL_AVAILABLE:
            return False
        try:
            self._ser = serial.Serial(port, BAUD, timeout=0)
            self._connected = True
            self._raw_bytes = 0
            self._last_rx_t = 0.0
            self._stop_evt.clear()
            self._buf.clear()
            self._thread = threading.Thread(
                target=self._reader_loop, daemon=True, name="uart-rx"
            )
            self._thread.start()
            return True
        except Exception:
            return False

    def disconnect(self):
        self._stop_evt.set()
        if self._ser:
            try:
                if self._ser.is_open:
                    self._ser.close()
            except Exception:
                pass
        self._connected = False
        self._latest    = None

    # ── Background RX thread ────────────────────────────────────────────────
    def _reader_loop(self):
        while not self._stop_evt.is_set():
            try:
                waiting = self._ser.in_waiting
                if waiting > 0:
                    raw = self._ser.read(waiting)
                    if raw:
                        with self._lock:
                            self._raw_bytes += len(raw)
                            self._last_rx_t  = time.monotonic()
                        self._buf.extend(raw)
                        self._parse_buf()
                else:
                    time.sleep(0.01)
            except Exception:
                self._connected = False
                break

    def _parse_buf(self):
        while len(self._buf) >= PKT_LEN_OLD:
            try:
                idx = self._buf.index(SOF)
            except ValueError:
                self._buf.clear()
                return
            if idx:
                self._err_count += idx
                del self._buf[:idx]

            # Prefer the longer (checksummed) packet when EOF lands at byte [5]
            if (len(self._buf) >= PKT_LEN_NEW
                    and self._buf[PKT_LEN_NEW - 1] == EOF_BYTE):
                pkt = bytes(self._buf[:PKT_LEN_NEW])
                del self._buf[:PKT_LEN_NEW]
                self._decode(pkt)
            elif (len(self._buf) >= PKT_LEN_OLD
                    and self._buf[PKT_LEN_OLD - 1] == EOF_BYTE):
                pkt = bytes(self._buf[:PKT_LEN_OLD])
                del self._buf[:PKT_LEN_OLD]
                self._decode(pkt)
            else:
                if len(self._buf) < PKT_LEN_NEW:
                    return   # wait for more data
                self._err_count += 1
                del self._buf[0]

    def _decode(self, pkt):
        # Checksum validation for 6-byte packets
        if len(pkt) == PKT_LEN_NEW and pkt[4] != (pkt[1] ^ pkt[2] ^ pkt[3]):
            with self._lock:
                self._err_count += 1
            return

        temp    = pkt[1]

        # pkt[2] = enc_pos_rf: absolute encoder position 0-200
        # The FPGA's quadrature_decoder accumulates the signed position counter;
        # Encoder.v takes abs() and clamps to 200 before sending.
        enc_pos = min(pkt[2], ENC_MAX)

        status  = pkt[3]
        reed    = bool(status & 0x04)   # bit 2 – reed sensor (trunk)
        fail    = bool(status & 0x02)   # bit 1 – TMR voter disagreement
        inj     = bool(status & 0x01)   # bit 0 – any fault bits active

        # Fault severity for the graph:
        #   0 = all three TMR copies agree
        #   1 = disagreement, no injection active (potential SEU)
        #   2 = disagreement AND fault reg non-zero (confirmed injection)
        if fail and inj:
            fault_level = 2
        elif fail:
            fault_level = 1
        else:
            fault_level = 0

        with self._lock:
            self._rx_count += 1
            self._latest = {
                "temperature": temp,
                "enc_pos":     enc_pos,
                "trunk_open":  reed,
                "fail_flag":   fail,
                "faults_any":  inj,
                "fault":       fault_level,
                "status_raw":  status,
            }

    # ── Fault injection TX ──────────────────────────────────────────────────
    def send_fault_cmd(self, mask18: int) -> bool:
        if not self._connected or not self._ser or not self._ser.is_open:
            return False
        b1 =  mask18        & 0xFF
        b2 = (mask18 >>  8) & 0xFF
        b3 = (mask18 >> 16) & 0x03
        try:
            self._ser.write(bytes([0xFF, b1, b2, b3]))
            return True
        except Exception:
            return False

    # ── Properties ──────────────────────────────────────────────────────────
    def read(self):
        with self._lock:
            return self._latest

    @property
    def connected(self):
        return self._connected

    @property
    def stats(self):
        with self._lock:
            return self._rx_count, self._err_count, self._raw_bytes, self._last_rx_t

    @staticmethod
    def list_ports():
        if not SERIAL_AVAILABLE:
            return ["(pyserial not installed)"]
        ports = [p.device for p in serial.tools.list_ports.comports()]
        return ports if ports else ["(no ports found)"]


# ══════════════════════════════════════════════════════════════════════════════
#  TMR Fault timeline graph
# ══════════════════════════════════════════════════════════════════════════════
class FaultGraph(tk.Canvas):
    W, H   = 520, 200
    MAXPTS = 150

    VOTER_OK    = "#1a4d2e"
    VOTER_OK_LN = GREEN
    VOTER_FAIL  = "#4d1a1a"
    VOTER_FL_LN = RED
    INJ_OFF     = "#1a1f26"
    INJ_OFF_LN  = DIMMED
    INJ_ON      = "#4d2a10"
    INJ_ON_LN   = ACCENT2

    PAD_L = 54
    PAD_R = 14
    PAD_T = 22
    PAD_B = 22
    GAP   = 6

    def __init__(self, parent):
        super().__init__(parent, width=self.W, height=self.H,
                         bg=PANEL, highlightthickness=1,
                         highlightbackground=BORDER)
        self._history = deque(maxlen=self.MAXPTS)
        self._draw_static()

    def _draw_static(self):
        pl = self.PAD_L
        pr = self.W - self.PAD_R
        pt = self.PAD_T
        pb = self.H - self.PAD_B

        mid          = (pt + pb) // 2
        self._t1_top = pt
        self._t1_bot = mid - self.GAP // 2
        self._t2_top = mid + self.GAP // 2
        self._t2_bot = pb
        self._pl     = pl
        self._pr     = pr

        for top, bot in ((self._t1_top, self._t1_bot),
                         (self._t2_top, self._t2_bot)):
            self.create_rectangle(pl, top, pr, bot,
                                  outline=BORDER, fill=BG, width=1)

        cy1 = (self._t1_top + self._t1_bot) // 2
        cy2 = (self._t2_top + self._t2_bot) // 2
        self.create_text(pl - 4, cy1, text="VOTER", anchor="e",
                         fill=GREEN, font=("Courier", 8, "bold"))
        self.create_text(pl - 4, cy2, text="INJECT", anchor="e",
                         fill=ACCENT2, font=("Courier", 8, "bold"))
        self.create_text(pl, 8, text="TMR FAULT TIMELINE",
                         anchor="w", fill=ACCENT, font=("Courier", 9, "bold"))
        self.create_text(pr, 8,
                         text="GREEN=agree  RED=disagree  ORANGE=inject",
                         anchor="e", fill=SUBTEXT, font=("Courier", 7))
        self.create_line(pr, pt - 4, pr, pb + 4,
                         fill=DIMMED, width=1, dash=(3, 3))
        self.create_text(pr, pb + 10, text="NOW", anchor="n",
                         fill=DIMMED, font=("Courier", 7))

    def push(self, fail_flag: bool, faults_any: bool):
        self._history.append((fail_flag, faults_any))
        self._redraw()

    def _redraw(self):
        self.delete("graph")
        pts = list(self._history)
        n   = len(pts)
        if n == 0:
            return

        pl, pr = self._pl, self._pr
        span   = pr - pl
        bar_w  = max(1, span // self.MAXPTS)

        for i, (fail, inj) in enumerate(pts):
            x1 = pr - (n - i) * bar_w
            x2 = x1 + bar_w
            if x2 < pl:
                continue

            fill1 = self.VOTER_FAIL if fail else self.VOTER_OK
            line1 = self.VOTER_FL_LN if fail else self.VOTER_OK_LN
            self.create_rectangle(x1, self._t1_top + 1, x2, self._t1_bot,
                                  fill=fill1, outline="", tags="graph")
            self.create_line(x1, self._t1_top + 1, x2, self._t1_top + 1,
                             fill=line1, width=2, tags="graph")

            fill2 = self.INJ_ON    if inj else self.INJ_OFF
            line2 = self.INJ_ON_LN if inj else self.INJ_OFF_LN
            self.create_rectangle(x1, self._t2_top, x2, self._t2_bot - 1,
                                  fill=fill2, outline="", tags="graph")
            self.create_line(x1, self._t2_top, x2, self._t2_top,
                             fill=line2, width=2, tags="graph")

        self.create_line(pr, self._t1_top, pr, self._t2_bot,
                         fill=TEXT, width=1, tags="graph")


# ══════════════════════════════════════════════════════════════════════════════
#  Arc gauge widget
# ══════════════════════════════════════════════════════════════════════════════
class ArcGauge(tk.Canvas):
    SIZE = 130

    def __init__(self, parent, label, unit, min_val=0, max_val=100, color=ACCENT):
        super().__init__(parent, width=self.SIZE, height=self.SIZE + 20,
                         bg=PANEL, highlightthickness=0)
        self._label = label
        self._unit  = unit
        self._min   = min_val
        self._max   = max_val
        self._color = color
        self._value = min_val
        self._draw()

    def set(self, value):
        self._value = max(self._min, min(self._max, value))
        self._draw()

    def _draw(self):
        self.delete("all")
        S, pad = self.SIZE, 14
        cx, cy = S // 2, S // 2 + 4
        r       = S // 2 - pad
        self.create_arc(cx - r, cy - r, cx + r, cy + r,
                        start=220, extent=-260,
                        style="arc", outline=BORDER, width=8)
        frac   = (self._value - self._min) / max(1, self._max - self._min)
        extent = -int(frac * 260)
        if extent:
            self.create_arc(cx - r, cy - r, cx + r, cy + r,
                            start=220, extent=extent,
                            style="arc", outline=self._color, width=8)
        self.create_text(cx, cy - 2, text=f"{self._value:.0f}",
                         fill=TEXT, font=("Courier", 16, "bold"))
        self.create_text(cx, cy + 16, text=self._unit,
                         fill=SUBTEXT, font=("Courier", 9))
        self.create_text(cx, S + 12, text=self._label,
                         fill=ACCENT, font=("Courier", 9, "bold"))


# ══════════════════════════════════════════════════════════════════════════════
#  Status tile
# ══════════════════════════════════════════════════════════════════════════════
class StatusTile(tk.Frame):
    def __init__(self, parent, label):
        super().__init__(parent, bg=PANEL,
                         highlightbackground=BORDER, highlightthickness=1)
        tk.Label(self, text=label, bg=PANEL, fg=SUBTEXT,
                 font=("Courier", 8, "bold")).pack(anchor="w", padx=10, pady=(6, 0))
        self._val = tk.Label(self, text="--", bg=PANEL, fg=TEXT,
                             font=("Courier", 18, "bold"))
        self._val.pack(anchor="w", padx=12, pady=(0, 6))

    def set(self, text, color=TEXT):
        self._val.config(text=text, fg=color)


# ══════════════════════════════════════════════════════════════════════════════
#  18-bit Fault Injection panel
# ══════════════════════════════════════════════════════════════════════════════
class FaultInjectPanel(tk.Frame):
    INSTANCES = [
        ("INSTANCE  A",  0),   # bits [5:0]
        ("INSTANCE  B",  6),   # bits [11:6]
        ("INSTANCE  C", 12),   # bits [17:12]
    ]

    def __init__(self, parent, fpga: SerialFPGA):
        super().__init__(parent, bg=PANEL,
                         highlightbackground=BORDER, highlightthickness=1)
        self._fpga   = fpga
        self._vars   = []
        self._status = tk.StringVar(value="")
        self._build()

    def _build(self):
        tk.Label(self, text="FAULT INJECTION REGISTER  (18-bit  |  PC -> FPGA)",
                 bg=PANEL, fg=ACCENT, font=("Courier", 9, "bold")
                 ).grid(row=0, column=0, columnspan=4, sticky="w",
                        padx=10, pady=(8, 4))

        col_frame = tk.Frame(self, bg=PANEL)
        col_frame.grid(row=1, column=0, columnspan=4, padx=10, pady=(0, 6))

        for _, (title, bit_offset) in enumerate(self.INSTANCES):
            grp = tk.Frame(col_frame, bg=PANEL,
                           highlightbackground=BORDER, highlightthickness=1)
            grp.pack(side="left", padx=(0, 10), pady=4, fill="y")
            tk.Label(grp, text=title, bg=PANEL, fg=ACCENT2,
                     font=("Courier", 8, "bold")
                     ).grid(row=0, column=0, columnspan=2, padx=6, pady=(6, 2))
            for b in range(6):
                v = tk.BooleanVar(value=False)
                self._vars.append(v)
                tk.Checkbutton(
                    grp, text=f"b{b + bit_offset}",
                    variable=v,
                    bg=PANEL, fg=TEXT, selectcolor=PANEL,
                    activebackground=PANEL, activeforeground=ACCENT2,
                    font=("Courier", 8),
                    command=self._on_change
                ).grid(row=1 + b // 2, column=b % 2, sticky="w", padx=6, pady=1)

        btn_row = tk.Frame(self, bg=PANEL)
        btn_row.grid(row=2, column=0, columnspan=4, sticky="w", padx=10, pady=(0, 8))

        tk.Button(btn_row, text="  SEND FAULTS",
                  command=self._send,
                  bg="#1c2128", fg=ACCENT2, activebackground="#2d1f1a",
                  activeforeground=ACCENT2, relief="flat", cursor="hand2",
                  font=("Courier", 9, "bold"), padx=12, pady=5,
                  highlightbackground=ACCENT2, highlightthickness=1
                  ).pack(side="left", padx=(0, 8))

        tk.Button(btn_row, text="X  CLEAR ALL",
                  command=self._clear,
                  bg="#1c2128", fg=SUBTEXT, activebackground="#1c2128",
                  activeforeground=TEXT, relief="flat", cursor="hand2",
                  font=("Courier", 9), padx=10, pady=5,
                  highlightbackground=BORDER, highlightthickness=1
                  ).pack(side="left", padx=(0, 14))

        tk.Label(btn_row, textvariable=self._status,
                 bg=PANEL, fg=YELLOW, font=("Courier", 9)
                 ).pack(side="left")

        self._hex_var = tk.StringVar(value="mask: 0x00000  (A=00  B=00  C=00)")
        tk.Label(self, textvariable=self._hex_var,
                 bg=PANEL, fg=SUBTEXT, font=("Courier", 8)
                 ).grid(row=3, column=0, columnspan=4, sticky="w",
                        padx=10, pady=(0, 8))

    def _mask(self) -> int:
        m = 0
        for i, v in enumerate(self._vars):
            if v.get():
                m |= (1 << i)
        return m

    def _on_change(self):
        m = self._mask()
        self._hex_var.set(
            f"mask: 0x{m:05X}  "
            f"(A=0x{m & 0x3F:02X}  "
            f"B=0x{(m >> 6) & 0x3F:02X}  "
            f"C=0x{(m >> 12) & 0x3F:02X})"
        )

    def _send(self):
        ok = self._fpga.send_fault_cmd(self._mask())
        self._status.set(f"Sent  0x{self._mask():05X}" if ok else "Not connected")
        self.after(2500, lambda: self._status.set(""))

    def _clear(self):
        for v in self._vars:
            v.set(False)
        self._on_change()
        self._fpga.send_fault_cmd(0)

    def get_mask(self) -> int:
        return self._mask()


# ══════════════════════════════════════════════════════════════════════════════
#  Connection bar
# ══════════════════════════════════════════════════════════════════════════════
class ConnectBar(tk.Frame):
    def __init__(self, parent, fpga: SerialFPGA, on_connect, on_disconnect):
        super().__init__(parent, bg=PANEL,
                         highlightbackground=BORDER, highlightthickness=1)
        self._fpga          = fpga
        self._on_connect    = on_connect
        self._on_disconnect = on_disconnect

        tk.Label(self, text="PORT:", bg=PANEL, fg=SUBTEXT,
                 font=("Courier", 9, "bold")).pack(side="left", padx=(10, 4), pady=6)

        self._port_var = tk.StringVar()
        self._combo    = ttk.Combobox(self, textvariable=self._port_var,
                                      width=12, font=("Courier", 9))
        self._combo.pack(side="left", padx=(0, 6), pady=6)
        self._refresh_ports()

        tk.Button(self, text="↺", command=self._refresh_ports,
                  bg=PANEL, fg=SUBTEXT, relief="flat", cursor="hand2",
                  font=("Courier", 10), padx=4
                  ).pack(side="left", padx=(0, 8))

        self._conn_btn = tk.Button(self, text="CONNECT",
                                   command=self._toggle,
                                   bg="#1c2128", fg=GREEN,
                                   activebackground="#1c2128",
                                   activeforeground=GREEN,
                                   relief="flat", cursor="hand2",
                                   font=("Courier", 9, "bold"),
                                   padx=10, pady=3,
                                   highlightbackground=GREEN,
                                   highlightthickness=1)
        self._conn_btn.pack(side="left", padx=(0, 12))

        self._dot  = tk.Label(self, text="●", bg=PANEL, fg=DIMMED,
                              font=("Courier", 11))
        self._dot.pack(side="left")
        self._stat = tk.Label(self, text="Disconnected",
                              bg=PANEL, fg=SUBTEXT, font=("Courier", 9))
        self._stat.pack(side="left", padx=(4, 16))

        tk.Label(self, text="115 200 baud  8N1  6-byte telemetry frame",
                 bg=PANEL, fg=DIMMED, font=("Courier", 8)
                 ).pack(side="right", padx=10)

    def _refresh_ports(self):
        ports = SerialFPGA.list_ports()
        self._combo["values"] = ports
        if ports and not self._port_var.get():
            self._port_var.set(ports[0])

    def _toggle(self):
        if self._fpga.connected:
            self._fpga.disconnect()
            self._on_disconnect()
            self._conn_btn.config(text="CONNECT", fg=GREEN,
                                  highlightbackground=GREEN)
            self._dot.config(fg=DIMMED)
            self._stat.config(text="Disconnected", fg=SUBTEXT)
        else:
            port = self._port_var.get()
            ok   = self._fpga.connect(port)
            if ok:
                self._on_connect()
                self._conn_btn.config(text="DISCONNECT", fg=RED,
                                      highlightbackground=RED)
                self._dot.config(fg=GREEN)
                self._stat.config(text=f"Connected  {port}", fg=GREEN)
            else:
                self._stat.config(text=f"Failed: {port}", fg=RED)
                self._dot.config(fg=RED)
                self.after(3000, lambda: self._stat.config(
                    text="Disconnected", fg=SUBTEXT))


# ══════════════════════════════════════════════════════════════════════════════
#  Main application
# ══════════════════════════════════════════════════════════════════════════════
class EVHub(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("EV Information System  --  TMR Fault Protection")
        self.configure(bg=BG)
        self.resizable(False, False)

        self._fpga        = SerialFPGA()
        self._fault_count = 0

        self._build_ui()
        self._poll()

    # ── Layout ──────────────────────────────────────────────────────────────
    def _build_ui(self):
        # Header
        hdr = tk.Frame(self, bg=BG)
        hdr.pack(fill="x", padx=20, pady=(14, 4))
        tk.Label(hdr, text="EV  INFORMATION  HUB",
                 bg=BG, fg=ACCENT, font=("Courier", 15, "bold")
                 ).pack(side="left")
        self._clock_lbl = tk.Label(hdr, text="", bg=BG, fg=SUBTEXT,
                                   font=("Courier", 9))
        self._clock_lbl.pack(side="right")

        # Connection bar
        self._conn_bar = ConnectBar(
            self, self._fpga,
            on_connect=self._on_connect,
            on_disconnect=self._on_disconnect
        )
        self._conn_bar.pack(fill="x", padx=20, pady=4)

        tk.Frame(self, bg=BORDER, height=1).pack(fill="x", padx=20, pady=4)

        # Body
        body = tk.Frame(self, bg=BG)
        body.pack(padx=20, pady=8)

        # Left column – fault graph + packet stats
        left = tk.Frame(body, bg=BG)
        left.grid(row=0, column=0, rowspan=2, padx=(0, 20), sticky="n")

        self._graph = FaultGraph(left)
        self._graph.pack()

        stats = tk.Frame(left, bg=PANEL,
                         highlightbackground=BORDER, highlightthickness=1)
        stats.pack(fill="x", pady=(6, 0))

        for col, (lbl, attr, default_color) in enumerate([
            ("RAW BYTES",     "_raw_lbl",         SUBTEXT),
            ("PKTS RX",       "_rx_lbl",           ACCENT),
            ("FRAME ERR",     "_err_lbl",          SUBTEXT),
            ("FAULTS LOGGED", "_fault_count_lbl",  ACCENT2),
        ]):
            tk.Label(stats, text=lbl, bg=PANEL, fg=SUBTEXT,
                     font=("Courier", 7)).grid(
                         row=0, column=col * 2,
                         padx=(8 if col == 0 else 6, 2), pady=5, sticky="w")
            lbl_w = tk.Label(stats, text="0", bg=PANEL, fg=default_color,
                             font=("Courier", 9, "bold"))
            lbl_w.grid(row=0, column=col * 2 + 1, padx=(0, 6), pady=5, sticky="w")
            setattr(self, attr, lbl_w)

        tk.Label(stats, text="LAST RX", bg=PANEL, fg=SUBTEXT,
                 font=("Courier", 7)).grid(row=0, column=8, padx=(6, 2), pady=5, sticky="w")
        self._age_lbl = tk.Label(stats, text="--", bg=PANEL, fg=SUBTEXT,
                                 font=("Courier", 9, "bold"))
        self._age_lbl.grid(row=0, column=9, padx=(0, 8), pady=5, sticky="w")

        # Right column – status tiles + gauges
        right = tk.Frame(body, bg=BG)
        right.grid(row=0, column=1, sticky="n")

        # Temperature
        temp_row = tk.Frame(right, bg=BG)
        temp_row.pack(fill="x", pady=(0, 6))
        self._temp_tile = StatusTile(temp_row, "TEMPERATURE  (I2C sensor)")
        self._temp_tile.pack(side="left", fill="both", expand=True, padx=(0, 8))
        self._temp_gauge = ArcGauge(temp_row, "TEMP", "C",
                                    min_val=0, max_val=120, color="#ff6b6b")
        self._temp_gauge.pack(side="left")

        # Encoder / throttle
        thr_row = tk.Frame(right, bg=BG)
        thr_row.pack(fill="x", pady=(0, 6))
        self._thr_tile = StatusTile(thr_row, "ENCODER POSITION  enc_pos_rf  (0 – 200)")
        self._thr_tile.pack(side="left", fill="both", expand=True, padx=(0, 8))
        self._thr_gauge = ArcGauge(thr_row, "THROTTLE", "%",
                                   min_val=0, max_val=100, color=GREEN)
        self._thr_gauge.pack(side="left")

        # Reed sensor
        self._trunk_tile = StatusTile(right, "REED SENSOR  reed_voted")
        self._trunk_tile.pack(fill="x", pady=(0, 6))

        # TMR voter fail flag
        self._fail_tile = StatusTile(right, "TMR VOTER  fail_flag")
        self._fail_tile.pack(fill="x", pady=(0, 6))

        # Fault injection echo
        self._inj_tile = StatusTile(right, "FAULT REGISTER  faults_any")
        self._inj_tile.pack(fill="x", pady=(0, 6))

        # Raw pkt[3] diagnostic
        self._raw_tile = StatusTile(right, "RAW  pkt[3]  {reed,fail,inj}")
        self._raw_tile.pack(fill="x")

        tk.Frame(self, bg=BORDER, height=1).pack(fill="x", padx=20, pady=8)

        # Fault injection panel
        tk.Label(self, text="UART FAULT INJECTION  ->  18-bit register  (PC -> FPGA RX)",
                 bg=BG, fg=SUBTEXT, font=("Courier", 8, "bold")
                 ).pack(anchor="w", padx=20)
        self._inject = FaultInjectPanel(self, self._fpga)
        self._inject.pack(padx=20, pady=(4, 16), anchor="w")

    # ── Connection callbacks ─────────────────────────────────────────────────
    def _on_connect(self):
        self._fault_count = 0
        self._fault_count_lbl.config(text="0")

    def _on_disconnect(self):
        for tile in (self._temp_tile, self._thr_tile, self._trunk_tile,
                     self._fail_tile, self._inj_tile, self._raw_tile):
            tile.set("--")

    # ── Polling loop ─────────────────────────────────────────────────────────
    def _poll(self):
        self._clock_lbl.config(text=time.strftime("%H:%M:%S"))

        rx_cnt, err_cnt, raw_bytes, last_rx_t = self._fpga.stats
        self._raw_lbl.config(text=str(raw_bytes))
        self._rx_lbl.config(text=str(rx_cnt))
        self._err_lbl.config(
            text=str(err_cnt),
            fg=(RED if err_cnt > 0 else SUBTEXT)
        )

        if self._fpga.connected:
            if last_rx_t == 0.0:
                self._age_lbl.config(text="waiting...", fg=YELLOW)
            else:
                age_ms = int((time.monotonic() - last_rx_t) * 1000)
                if age_ms < 300:
                    age_txt, age_col = f"{age_ms} ms", GREEN
                elif age_ms < 1000:
                    age_txt, age_col = f"{age_ms} ms", YELLOW
                else:
                    age_txt, age_col = f"{age_ms//1000}.{(age_ms%1000)//100}s  STALE", RED
                self._age_lbl.config(text=age_txt, fg=age_col)
        else:
            self._age_lbl.config(text="--", fg=SUBTEXT)

        data = self._fpga.read()
        if data is not None:
            self._update_ui(data)

        self.after(UPDATE_MS, self._poll)

    def _update_ui(self, data: dict):
        self._graph.push(data["fail_flag"], data["faults_any"])

        # Temperature
        t     = data["temperature"]
        t_col = GREEN if t < 50 else (YELLOW if t < 80 else RED)
        self._temp_tile.set(f"{t} C", t_col)
        self._temp_gauge.set(t)

        # Encoder position – absolute value from FPGA, 0-200 → displayed as 0-100%
        pos     = data["enc_pos"]
        pct     = round(pos / ENC_MAX * 100)
        pct_col = GREEN if pct < 70 else (YELLOW if pct < 90 else RED)
        self._thr_tile.set(f"{pct} %  (pos {pos})", pct_col)
        self._thr_gauge.set(pct)

        # Reed sensor
        if data["trunk_open"]:
            self._trunk_tile.set("TRIGGERED  [1]", YELLOW)
        else:
            self._trunk_tile.set("CLEAR  [0]", GREEN)

        # TMR voter fail flag
        if data["fail_flag"]:
            self._fail_tile.set("DISAGREE  !", RED)
            self._fault_count += 1
            self._fault_count_lbl.config(text=str(self._fault_count))
        else:
            self._fail_tile.set("AGREE  OK", GREEN)

        # Fault injection echo
        mask = self._inject.get_mask()
        if data["faults_any"]:
            self._inj_tile.set(f"ACTIVE  0x{mask:05X}", ACCENT2)
        else:
            self._inj_tile.set("INACTIVE  [0]", SUBTEXT)

        # Raw pkt[3] diagnostic
        s      = data["status_raw"]
        reed_b = (s >> 2) & 1
        fail_b = (s >> 1) & 1
        inj_b  =  s       & 1
        raw_col = ACCENT if (fail_b or inj_b) else SUBTEXT
        self._raw_tile.set(
            f"0x{s:02X}  r={reed_b} f={fail_b} i={inj_b}", raw_col
        )


# ── Entry point ────────────────────────────────────────────────────────────────
if __name__ == "__main__":
    if not SERIAL_AVAILABLE:
        print("WARNING: pyserial not installed.")
        print("         Run:  pip install pyserial")
        print("         The GUI will open but cannot connect to hardware.\n")
    app = EVHub()
    app.mainloop()
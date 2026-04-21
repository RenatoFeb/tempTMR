module spi_master_tmr_wrapper (
    clk,
    rst,
    start,
    tx_data,
    bit_count,
    clk_div,
    cpol,
    cpha,
    miso,
    sclk,
    mosi,
    cs,
    rx_data,
    busy,
    done,
    flip_a,
    flip_b,
    flip_c,
    fail_flag
);

input clk;
input rst;
input start;
input [31:0] tx_data;
input [5:0] bit_count;
input [15:0] clk_div;
input cpol;
input cpha;
input miso;
output sclk;
output mosi;
output cs;
output [31:0] rx_data;
output busy;
output done;
input flip_a, flip_b, flip_c;
output fail_flag;

wire clk_a = clk;
wire clk_b = clk;
wire clk_c = clk;

wire rst_a = rst;
wire rst_b = rst;
wire rst_c = rst;

wire start_a, start_b, start_c;
assign start_a = start ^ {1{flip_a}};
assign start_b = start ^ {1{flip_b}};
assign start_c = start ^ {1{flip_c}};

wire [31:0] tx_data_a, tx_data_b, tx_data_c;
assign tx_data_a = tx_data ^ {32{flip_a}};
assign tx_data_b = tx_data ^ {32{flip_b}};
assign tx_data_c = tx_data ^ {32{flip_c}};

wire [5:0] bit_count_a, bit_count_b, bit_count_c;
assign bit_count_a = bit_count ^ {6{flip_a}};
assign bit_count_b = bit_count ^ {6{flip_b}};
assign bit_count_c = bit_count ^ {6{flip_c}};

wire [15:0] clk_div_a, clk_div_b, clk_div_c;
assign clk_div_a = clk_div ^ {16{flip_a}};
assign clk_div_b = clk_div ^ {16{flip_b}};
assign clk_div_c = clk_div ^ {16{flip_c}};

wire cpol_a, cpol_b, cpol_c;
assign cpol_a = cpol ^ {1{flip_a}};
assign cpol_b = cpol ^ {1{flip_b}};
assign cpol_c = cpol ^ {1{flip_c}};

wire cpha_a, cpha_b, cpha_c;
assign cpha_a = cpha ^ {1{flip_a}};
assign cpha_b = cpha ^ {1{flip_b}};
assign cpha_c = cpha ^ {1{flip_c}};

wire miso_a, miso_b, miso_c;
assign miso_a = miso ^ {1{flip_a}};
assign miso_b = miso ^ {1{flip_b}};
assign miso_c = miso ^ {1{flip_c}};

wire sclk_a, sclk_b, sclk_c;
wire mosi_a, mosi_b, mosi_c;
wire cs_a, cs_b, cs_c;
wire [31:0] rx_data_a, rx_data_b, rx_data_c;
wire busy_a, busy_b, busy_c;
wire done_a, done_b, done_c;

spi_master u_a (
    .clk(clk_a),
    .rst(rst_a),
    .start(start_a),
    .tx_data(tx_data_a),
    .bit_count(bit_count_a),
    .clk_div(clk_div_a),
    .cpol(cpol_a),
    .cpha(cpha_a),
    .miso(miso_a),
    .sclk(sclk_a),
    .mosi(mosi_a),
    .cs(cs_a),
    .rx_data(rx_data_a),
    .busy(busy_a),
    .done(done_a)
);

spi_master u_b (
    .clk(clk_b),
    .rst(rst_b),
    .start(start_b),
    .tx_data(tx_data_b),
    .bit_count(bit_count_b),
    .clk_div(clk_div_b),
    .cpol(cpol_b),
    .cpha(cpha_b),
    .miso(miso_b),
    .sclk(sclk_b),
    .mosi(mosi_b),
    .cs(cs_b),
    .rx_data(rx_data_b),
    .busy(busy_b),
    .done(done_b)
);

spi_master u_c (
    .clk(clk_c),
    .rst(rst_c),
    .start(start_c),
    .tx_data(tx_data_c),
    .bit_count(bit_count_c),
    .clk_div(clk_div_c),
    .cpol(cpol_c),
    .cpha(cpha_c),
    .miso(miso_c),
    .sclk(sclk_c),
    .mosi(mosi_c),
    .cs(cs_c),
    .rx_data(rx_data_c),
    .busy(busy_c),
    .done(done_c)
);

assign sclk = (sclk_a & sclk_b) | (sclk_b & sclk_c) | (sclk_a & sclk_c);
wire sclk_fail_bits = (sclk_a ^ sclk_b) & (sclk_b ^ sclk_c);

assign mosi = (mosi_a & mosi_b) | (mosi_b & mosi_c) | (mosi_a & mosi_c);
wire mosi_fail_bits = (mosi_a ^ mosi_b) & (mosi_b ^ mosi_c);

assign cs = (cs_a & cs_b) | (cs_b & cs_c) | (cs_a & cs_c);
wire cs_fail_bits = (cs_a ^ cs_b) & (cs_b ^ cs_c);

assign rx_data = (rx_data_a & rx_data_b) | (rx_data_b & rx_data_c) | (rx_data_a & rx_data_c);
wire [31:0] rx_data_fail_bits = (rx_data_a ^ rx_data_b) & (rx_data_b ^ rx_data_c);

assign busy = (busy_a & busy_b) | (busy_b & busy_c) | (busy_a & busy_c);
wire busy_fail_bits = (busy_a ^ busy_b) & (busy_b ^ busy_c);

assign done = (done_a & done_b) | (done_b & done_c) | (done_a & done_c);
wire done_fail_bits = (done_a ^ done_b) & (done_b ^ done_c);

assign fail_flag = |sclk_fail_bits | |mosi_fail_bits | |cs_fail_bits | |rx_data_fail_bits | |busy_fail_bits | |done_fail_bits;

endmodule
module mcp3910_ctrl_tmr_wrapper (
    clk,
    spi_rx,
    spi_done,
    spi_start,
    spi_tx,
    spi_bits,
    adc_data,
    flip_a,
    flip_b,
    flip_c,
    fail_flag
);

input clk;
input [31:0] spi_rx;
input spi_done;
output spi_start;
output [31:0] spi_tx;
output [5:0] spi_bits;
output [23:0] adc_data;
input flip_a, flip_b, flip_c;
output fail_flag;

wire clk_a = clk;
wire clk_b = clk;
wire clk_c = clk;

wire [31:0] spi_rx_a, spi_rx_b, spi_rx_c;
assign spi_rx_a = spi_rx ^ {32{flip_a}};
assign spi_rx_b = spi_rx ^ {32{flip_b}};
assign spi_rx_c = spi_rx ^ {32{flip_c}};

wire spi_done_a, spi_done_b, spi_done_c;
assign spi_done_a = spi_done ^ {1{flip_a}};
assign spi_done_b = spi_done ^ {1{flip_b}};
assign spi_done_c = spi_done ^ {1{flip_c}};

wire spi_start_a, spi_start_b, spi_start_c;
wire [31:0] spi_tx_a, spi_tx_b, spi_tx_c;
wire [5:0] spi_bits_a, spi_bits_b, spi_bits_c;
wire [23:0] adc_data_a, adc_data_b, adc_data_c;

mcp3910_ctrl u_a (
    .clk(clk_a),
    .spi_rx(spi_rx_a),
    .spi_done(spi_done_a),
    .spi_start(spi_start_a),
    .spi_tx(spi_tx_a),
    .spi_bits(spi_bits_a),
    .adc_data(adc_data_a)
);

mcp3910_ctrl u_b (
    .clk(clk_b),
    .spi_rx(spi_rx_b),
    .spi_done(spi_done_b),
    .spi_start(spi_start_b),
    .spi_tx(spi_tx_b),
    .spi_bits(spi_bits_b),
    .adc_data(adc_data_b)
);

mcp3910_ctrl u_c (
    .clk(clk_c),
    .spi_rx(spi_rx_c),
    .spi_done(spi_done_c),
    .spi_start(spi_start_c),
    .spi_tx(spi_tx_c),
    .spi_bits(spi_bits_c),
    .adc_data(adc_data_c)
);

assign spi_start = (spi_start_a & spi_start_b) | (spi_start_b & spi_start_c) | (spi_start_a & spi_start_c);
wire spi_start_fail_bits = (spi_start_a ^ spi_start_b) & (spi_start_b ^ spi_start_c);

assign spi_tx = (spi_tx_a & spi_tx_b) | (spi_tx_b & spi_tx_c) | (spi_tx_a & spi_tx_c);
wire [31:0] spi_tx_fail_bits = (spi_tx_a ^ spi_tx_b) & (spi_tx_b ^ spi_tx_c);

assign spi_bits = (spi_bits_a & spi_bits_b) | (spi_bits_b & spi_bits_c) | (spi_bits_a & spi_bits_c);
wire [5:0] spi_bits_fail_bits = (spi_bits_a ^ spi_bits_b) & (spi_bits_b ^ spi_bits_c);

assign adc_data = (adc_data_a & adc_data_b) | (adc_data_b & adc_data_c) | (adc_data_a & adc_data_c);
wire [23:0] adc_data_fail_bits = (adc_data_a ^ adc_data_b) & (adc_data_b ^ adc_data_c);

assign fail_flag = |spi_start_fail_bits | |spi_tx_fail_bits | |spi_bits_fail_bits | |adc_data_fail_bits;

endmodule
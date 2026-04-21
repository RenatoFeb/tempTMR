`timescale 1ns / 1ps


module SPI(
    input CLK100MHZ,
    input ACL_MISO,
    output ACL_MOSI,
    output ACL_SCLK,
    output ACL_CSN,
    output [23:0] adc_data
);

wire clk_spi;
wire spi_start;
wire [31:0] spi_tx;
wire [31:0] spi_rx;
wire [5:0] spi_bits;
wire spi_done;
wire spi_busy;

clkgen_4MHz_tmr_wrapper cg(
    .CLK100MHZ(CLK100MHZ),
    .clk_4MHz(clk_spi)
);


spi_master_tmr_wrapper spi0(
    .clk(clk_spi),
    .rst(1'b0),

    .start(spi_start),
    .tx_data(spi_tx),
    .bit_count(spi_bits),
    .clk_div(16'd4),

    .cpol(0),
    .cpha(0),

    .sclk(ACL_SCLK),
    .mosi(ACL_MOSI),
    .miso(ACL_MISO),
    .cs(ACL_CSN),

    .rx_data(spi_rx),
    .busy(spi_busy),
    .done(spi_done)
);


mcp3910_ctrl_tmr_wrapper adc(
    .clk(clk_spi),

    .spi_start(spi_start),
    .spi_tx(spi_tx),
    .spi_bits(spi_bits),
    .spi_rx(spi_rx),
    .spi_done(spi_done),

    .adc_data(adc_data)
);

battery_display_tmr_wrapper display(
    .CLK100MHZ(CLK100MHZ),
    .adc_value(adc_data),
    .seg(SEG),
    .dp(DP),
    .an(AN)
);

endmodule

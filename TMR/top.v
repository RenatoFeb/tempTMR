`timescale 1ns / 1ps

module top(
    input         CLK100MHZ,
    input         reset,
    input  [7:0]  temp_data,
    output [6:0]  SEG,
    output        DP,
    output [7:0]  AN
);

wire [23:0] adc_data;
wire [7:0]  an;
wire        ACL_MISO;
wire        ACL_MOSI;
wire        ACL_SCLK;
wire        ACL_CSN;
wire [3:0]  NAN;

assign AN = an & 8'b00001111;

SPI_tmr_wrapper spi(
    .CLK100MHZ(CLK100MHZ),
    .ACL_MISO(ACL_MISO),
    .ACL_MOSI(ACL_MOSI),
    .ACL_SCLK(ACL_SCLK),
    .adc_data(adc_data),
    .ACL_CSN(ACL_CSN)
);

diplayModule_tmr_wrapper display(
    .CLK100MHZ(CLK100MHZ),
    .adc_value(adc_data),
    .temp_data(temp_data),
    .NAN(NAN),
    .seg(SEG),
    .dp(DP),
    .an(an)
);

endmodule

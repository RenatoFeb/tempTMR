`timescale 1ns / 1ps

module tempSens(
    input        CLK100MHZ,
    input        reset,
    inout        TMP_SDA,
    output       TMP_SCL,
    output [7:0] w_data
);

    wire sda_dir;
    wire w_200kHz;

    clkgen_200kHz cgen(
        .clk_100MHz(CLK100MHZ),
        .clk_200kHz(w_200kHz)
    );

    i2c_master master(
        .clk_200kHz(w_200kHz),
        .reset(reset),
        .temp_data(w_data),
        .SDA(TMP_SDA),
        .SDA_dir(sda_dir),
        .SCL(TMP_SCL)
    );

endmodule

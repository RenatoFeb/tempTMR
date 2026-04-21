module SPI_tmr_wrapper (
    CLK100MHZ,
    ACL_MISO,
    ACL_MOSI,
    ACL_SCLK,
    ACL_CSN,
    adc_data,
    flip_a,
    flip_b,
    flip_c,
    fail_flag
);

input CLK100MHZ;
input ACL_MISO;
output ACL_MOSI;
output ACL_SCLK;
output ACL_CSN;
output [23:0] adc_data;
input flip_a, flip_b, flip_c;
output fail_flag;

wire CLK100MHZ_a, CLK100MHZ_b, CLK100MHZ_c;
assign CLK100MHZ_a = CLK100MHZ ^ {1{flip_a}};
assign CLK100MHZ_b = CLK100MHZ ^ {1{flip_b}};
assign CLK100MHZ_c = CLK100MHZ ^ {1{flip_c}};

wire ACL_MISO_a, ACL_MISO_b, ACL_MISO_c;
assign ACL_MISO_a = ACL_MISO ^ {1{flip_a}};
assign ACL_MISO_b = ACL_MISO ^ {1{flip_b}};
assign ACL_MISO_c = ACL_MISO ^ {1{flip_c}};

wire ACL_MOSI_a, ACL_MOSI_b, ACL_MOSI_c;
wire ACL_SCLK_a, ACL_SCLK_b, ACL_SCLK_c;
wire ACL_CSN_a, ACL_CSN_b, ACL_CSN_c;
wire [23:0] adc_data_a, adc_data_b, adc_data_c;

SPI u_a (
    .CLK100MHZ(CLK100MHZ_a),
    .ACL_MISO(ACL_MISO_a),
    .ACL_MOSI(ACL_MOSI_a),
    .ACL_SCLK(ACL_SCLK_a),
    .ACL_CSN(ACL_CSN_a),
    .adc_data(adc_data_a)
);

SPI u_b (
    .CLK100MHZ(CLK100MHZ_b),
    .ACL_MISO(ACL_MISO_b),
    .ACL_MOSI(ACL_MOSI_b),
    .ACL_SCLK(ACL_SCLK_b),
    .ACL_CSN(ACL_CSN_b),
    .adc_data(adc_data_b)
);

SPI u_c (
    .CLK100MHZ(CLK100MHZ_c),
    .ACL_MISO(ACL_MISO_c),
    .ACL_MOSI(ACL_MOSI_c),
    .ACL_SCLK(ACL_SCLK_c),
    .ACL_CSN(ACL_CSN_c),
    .adc_data(adc_data_c)
);

assign ACL_MOSI = (ACL_MOSI_a & ACL_MOSI_b) | (ACL_MOSI_b & ACL_MOSI_c) | (ACL_MOSI_a & ACL_MOSI_c);
wire ACL_MOSI_fail_bits = (ACL_MOSI_a ^ ACL_MOSI_b) & (ACL_MOSI_b ^ ACL_MOSI_c);

assign ACL_SCLK = (ACL_SCLK_a & ACL_SCLK_b) | (ACL_SCLK_b & ACL_SCLK_c) | (ACL_SCLK_a & ACL_SCLK_c);
wire ACL_SCLK_fail_bits = (ACL_SCLK_a ^ ACL_SCLK_b) & (ACL_SCLK_b ^ ACL_SCLK_c);

assign ACL_CSN = (ACL_CSN_a & ACL_CSN_b) | (ACL_CSN_b & ACL_CSN_c) | (ACL_CSN_a & ACL_CSN_c);
wire ACL_CSN_fail_bits = (ACL_CSN_a ^ ACL_CSN_b) & (ACL_CSN_b ^ ACL_CSN_c);

assign adc_data = (adc_data_a & adc_data_b) | (adc_data_b & adc_data_c) | (adc_data_a & adc_data_c);
wire [23:0] adc_data_fail_bits = (adc_data_a ^ adc_data_b) & (adc_data_b ^ adc_data_c);

assign fail_flag = |ACL_MOSI_fail_bits | |ACL_SCLK_fail_bits | |ACL_CSN_fail_bits | |adc_data_fail_bits;

endmodule
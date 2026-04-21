module diplayModule_tmr_wrapper (
    CLK100MHZ,
    adc_value,
    temp_data,
    NAN,
    seg,
    dp,
    an,
    flip_a,
    flip_b,
    flip_c,
    fail_flag
);

input CLK100MHZ;
input [23:0] adc_value;
input [7:0] temp_data;
output [3:0] NAN;
output [6:0] seg;
output dp;
output [7:0] an;
input flip_a, flip_b, flip_c;
output fail_flag;

wire CLK100MHZ_a, CLK100MHZ_b, CLK100MHZ_c;
assign CLK100MHZ_a = CLK100MHZ ^ {1{flip_a}};
assign CLK100MHZ_b = CLK100MHZ ^ {1{flip_b}};
assign CLK100MHZ_c = CLK100MHZ ^ {1{flip_c}};

wire [23:0] adc_value_a, adc_value_b, adc_value_c;
assign adc_value_a = adc_value ^ {24{flip_a}};
assign adc_value_b = adc_value ^ {24{flip_b}};
assign adc_value_c = adc_value ^ {24{flip_c}};

wire [7:0] temp_data_a, temp_data_b, temp_data_c;
assign temp_data_a = temp_data ^ {8{flip_a}};
assign temp_data_b = temp_data ^ {8{flip_b}};
assign temp_data_c = temp_data ^ {8{flip_c}};

wire [3:0] NAN_a, NAN_b, NAN_c;
wire [6:0] seg_a, seg_b, seg_c;
wire dp_a, dp_b, dp_c;
wire [7:0] an_a, an_b, an_c;

diplayModule u_a (
    .CLK100MHZ(CLK100MHZ_a),
    .adc_value(adc_value_a),
    .temp_data(temp_data_a),
    .NAN(NAN_a),
    .seg(seg_a),
    .dp(dp_a),
    .an(an_a)
);

diplayModule u_b (
    .CLK100MHZ(CLK100MHZ_b),
    .adc_value(adc_value_b),
    .temp_data(temp_data_b),
    .NAN(NAN_b),
    .seg(seg_b),
    .dp(dp_b),
    .an(an_b)
);

diplayModule u_c (
    .CLK100MHZ(CLK100MHZ_c),
    .adc_value(adc_value_c),
    .temp_data(temp_data_c),
    .NAN(NAN_c),
    .seg(seg_c),
    .dp(dp_c),
    .an(an_c)
);

assign NAN = (NAN_a & NAN_b) | (NAN_b & NAN_c) | (NAN_a & NAN_c);
wire [3:0] NAN_fail_bits = (NAN_a ^ NAN_b) & (NAN_b ^ NAN_c);

assign seg = (seg_a & seg_b) | (seg_b & seg_c) | (seg_a & seg_c);
wire [6:0] seg_fail_bits = (seg_a ^ seg_b) & (seg_b ^ seg_c);

assign dp = (dp_a & dp_b) | (dp_b & dp_c) | (dp_a & dp_c);
wire dp_fail_bits = (dp_a ^ dp_b) & (dp_b ^ dp_c);

assign an = (an_a & an_b) | (an_b & an_c) | (an_a & an_c);
wire [7:0] an_fail_bits = (an_a ^ an_b) & (an_b ^ an_c);

assign fail_flag = |NAN_fail_bits | |seg_fail_bits | |dp_fail_bits | |an_fail_bits;

endmodule
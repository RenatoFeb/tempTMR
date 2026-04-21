module top_tmr_wrapper (
    CLK100MHZ,
    reset,
    temp_data,
    SEG,
    DP,
    AN,
    flip_a,
    flip_b,
    flip_c,
    fail_flag
);

input CLK100MHZ;
input reset;
input [7:0] temp_data;
output [6:0] SEG;
output DP;
output [7:0] AN;
input flip_a, flip_b, flip_c;
output fail_flag;

wire CLK100MHZ_a, CLK100MHZ_b, CLK100MHZ_c;
assign CLK100MHZ_a = CLK100MHZ ^ {1{flip_a}};
assign CLK100MHZ_b = CLK100MHZ ^ {1{flip_b}};
assign CLK100MHZ_c = CLK100MHZ ^ {1{flip_c}};

wire reset_a = reset;
wire reset_b = reset;
wire reset_c = reset;

wire [6:0] SEG_a, SEG_b, SEG_c;
wire DP_a, DP_b, DP_c;
wire [7:0] AN_a, AN_b, AN_c;

top u_a (
    .CLK100MHZ(CLK100MHZ_a),
    .reset(reset_a),
    .temp_data(temp_data),
    .SEG(SEG_a),
    .DP(DP_a),
    .AN(AN_a)
);

top u_b (
    .CLK100MHZ(CLK100MHZ_b),
    .reset(reset_b),
    .temp_data(temp_data),
    .SEG(SEG_b),
    .DP(DP_b),
    .AN(AN_b)
);

top u_c (
    .CLK100MHZ(CLK100MHZ_c),
    .reset(reset_c),
    .temp_data(temp_data),
    .SEG(SEG_c),
    .DP(DP_c),
    .AN(AN_c)
);

assign SEG = (SEG_a & SEG_b) | (SEG_b & SEG_c) | (SEG_a & SEG_c);
wire [6:0] SEG_fail_bits = (SEG_a ^ SEG_b) & (SEG_b ^ SEG_c);

assign DP = (DP_a & DP_b) | (DP_b & DP_c) | (DP_a & DP_c);
wire DP_fail_bits = (DP_a ^ DP_b) & (DP_b ^ DP_c);

assign AN = (AN_a & AN_b) | (AN_b & AN_c) | (AN_a & AN_c);
wire [7:0] AN_fail_bits = (AN_a ^ AN_b) & (AN_b ^ AN_c);

assign fail_flag = |SEG_fail_bits | |DP_fail_bits | |AN_fail_bits;

endmodule

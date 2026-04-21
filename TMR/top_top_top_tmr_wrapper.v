module top_top_top_tmr_wrapper(
    reset,
    clk,
    enc_a,
    enc_b,
    enc_btn_n,
    dir_switch_r,
    dir_switch_l,
    reed_in,
    TMP_SDA,
    TMP_SCL,
    SEG,
    DP,
    AN,
    MOTOR_RF,
    MOTOR_LF,
    MOTOR_RB,
    MOTOR_LB,
    led0,
    flip_a,
    flip_b,
    flip_c,
    fail_flag
);

input reset;
input clk;
input enc_a;
input enc_b;
input enc_btn_n;
input dir_switch_r;
input dir_switch_l;
input reed_in;
inout TMP_SDA;
output TMP_SCL;
output [6:0] SEG;
output DP;
output [3:0] AN;
output [2:0] MOTOR_RF;
output [2:0] MOTOR_LF;
output [2:0] MOTOR_RB;
output [2:0] MOTOR_LB;
output led0;
input flip_a, flip_b, flip_c;
output fail_flag;

// Single I2C master outside the TMR region — cannot triplicate a bidirectional bus
wire [7:0] temp_data;
tempSens i2c_sens(
    .CLK100MHZ(clk),
    .reset(reset),
    .TMP_SDA(TMP_SDA),
    .TMP_SCL(TMP_SCL),
    .w_data(temp_data)
);

wire reset_a = reset;
wire reset_b = reset;
wire reset_c = reset;

wire clk_a = clk;
wire clk_b = clk;
wire clk_c = clk;

wire enc_a_a, enc_a_b, enc_a_c;
assign enc_a_a = enc_a ^ {1{flip_a}};
assign enc_a_b = enc_a ^ {1{flip_b}};
assign enc_a_c = enc_a ^ {1{flip_c}};

wire enc_b_a, enc_b_b, enc_b_c;
assign enc_b_a = enc_b ^ {1{flip_a}};
assign enc_b_b = enc_b ^ {1{flip_b}};
assign enc_b_c = enc_b ^ {1{flip_c}};

wire enc_btn_n_a, enc_btn_n_b, enc_btn_n_c;
assign enc_btn_n_a = enc_btn_n ^ {1{flip_a}};
assign enc_btn_n_b = enc_btn_n ^ {1{flip_b}};
assign enc_btn_n_c = enc_btn_n ^ {1{flip_c}};

wire dir_switch_r_a, dir_switch_r_b, dir_switch_r_c;
assign dir_switch_r_a = dir_switch_r ^ {1{flip_a}};
assign dir_switch_r_b = dir_switch_r ^ {1{flip_b}};
assign dir_switch_r_c = dir_switch_r ^ {1{flip_c}};

wire dir_switch_l_a, dir_switch_l_b, dir_switch_l_c;
assign dir_switch_l_a = dir_switch_l ^ {1{flip_a}};
assign dir_switch_l_b = dir_switch_l ^ {1{flip_b}};
assign dir_switch_l_c = dir_switch_l ^ {1{flip_c}};

wire reed_in_a, reed_in_b, reed_in_c;
assign reed_in_a = reed_in ^ {1{flip_a}};
assign reed_in_b = reed_in ^ {1{flip_b}};
assign reed_in_c = reed_in ^ {1{flip_c}};

wire [6:0] SEG_a, SEG_b, SEG_c;
wire DP_a, DP_b, DP_c;
wire [3:0] AN_a, AN_b, AN_c;
wire [2:0] MOTOR_RF_a, MOTOR_RF_b, MOTOR_RF_c;
wire [2:0] MOTOR_LF_a, MOTOR_LF_b, MOTOR_LF_c;
wire [2:0] MOTOR_RB_a, MOTOR_RB_b, MOTOR_RB_c;
wire [2:0] MOTOR_LB_a, MOTOR_LB_b, MOTOR_LB_c;
wire led0_a, led0_b, led0_c;

top_top_top u_a (
    .reset(reset_a),
    .clk(clk_a),
    .enc_a(enc_a_a),
    .enc_b(enc_b_a),
    .enc_btn_n(enc_btn_n_a),
    .dir_switch_r(dir_switch_r_a),
    .dir_switch_l(dir_switch_l_a),
    .reed_in(reed_in_a),
    .temp_data(temp_data),
    .SEG(SEG_a),
    .DP(DP_a),
    .AN(AN_a),
    .MOTOR_RF(MOTOR_RF_a),
    .MOTOR_LF(MOTOR_LF_a),
    .MOTOR_RB(MOTOR_RB_a),
    .MOTOR_LB(MOTOR_LB_a),
    .led0(led0_a)
);

top_top_top u_b (
    .reset(reset_b),
    .clk(clk_b),
    .enc_a(enc_a_b),
    .enc_b(enc_b_b),
    .enc_btn_n(enc_btn_n_b),
    .dir_switch_r(dir_switch_r_b),
    .dir_switch_l(dir_switch_l_b),
    .reed_in(reed_in_b),
    .temp_data(temp_data),
    .SEG(SEG_b),
    .DP(DP_b),
    .AN(AN_b),
    .MOTOR_RF(MOTOR_RF_b),
    .MOTOR_LF(MOTOR_LF_b),
    .MOTOR_RB(MOTOR_RB_b),
    .MOTOR_LB(MOTOR_LB_b),
    .led0(led0_b)
);

top_top_top u_c (
    .reset(reset_c),
    .clk(clk_c),
    .enc_a(enc_a_c),
    .enc_b(enc_b_c),
    .enc_btn_n(enc_btn_n_c),
    .dir_switch_r(dir_switch_r_c),
    .dir_switch_l(dir_switch_l_c),
    .reed_in(reed_in_c),
    .temp_data(temp_data),
    .SEG(SEG_c),
    .DP(DP_c),
    .AN(AN_c),
    .MOTOR_RF(MOTOR_RF_c),
    .MOTOR_LF(MOTOR_LF_c),
    .MOTOR_RB(MOTOR_RB_c),
    .MOTOR_LB(MOTOR_LB_c),
    .led0(led0_c)
);

assign SEG = (SEG_a & SEG_b) | (SEG_b & SEG_c) | (SEG_a & SEG_c);
wire [6:0] SEG_fail_bits = (SEG_a ^ SEG_b) & (SEG_b ^ SEG_c);

assign DP = (DP_a & DP_b) | (DP_b & DP_c) | (DP_a & DP_c);
wire DP_fail_bits = (DP_a ^ DP_b) & (DP_b ^ DP_c);

assign AN = (AN_a & AN_b) | (AN_b & AN_c) | (AN_a & AN_c);
wire [3:0] AN_fail_bits = (AN_a ^ AN_b) & (AN_b ^ AN_c);

assign MOTOR_RF = (MOTOR_RF_a & MOTOR_RF_b) | (MOTOR_RF_b & MOTOR_RF_c) | (MOTOR_RF_a & MOTOR_RF_c);
wire [2:0] MOTOR_RF_fail_bits = (MOTOR_RF_a ^ MOTOR_RF_b) & (MOTOR_RF_b ^ MOTOR_RF_c);

assign MOTOR_LF = (MOTOR_LF_a & MOTOR_LF_b) | (MOTOR_LF_b & MOTOR_LF_c) | (MOTOR_LF_a & MOTOR_LF_c);
wire [2:0] MOTOR_LF_fail_bits = (MOTOR_LF_a ^ MOTOR_LF_b) & (MOTOR_LF_b ^ MOTOR_LF_c);

assign MOTOR_RB = (MOTOR_RB_a & MOTOR_RB_b) | (MOTOR_RB_b & MOTOR_RB_c) | (MOTOR_RB_a & MOTOR_RB_c);
wire [2:0] MOTOR_RB_fail_bits = (MOTOR_RB_a ^ MOTOR_RB_b) & (MOTOR_RB_b ^ MOTOR_RB_c);

assign MOTOR_LB = (MOTOR_LB_a & MOTOR_LB_b) | (MOTOR_LB_b & MOTOR_LB_c) | (MOTOR_LB_a & MOTOR_LB_c);
wire [2:0] MOTOR_LB_fail_bits = (MOTOR_LB_a ^ MOTOR_LB_b) & (MOTOR_LB_b ^ MOTOR_LB_c);

assign led0 = (led0_a & led0_b) | (led0_b & led0_c) | (led0_a & led0_c);
wire led0_fail_bits = (led0_a ^ led0_b) & (led0_b ^ led0_c);

assign fail_flag = |SEG_fail_bits | |DP_fail_bits | |AN_fail_bits |
                   |MOTOR_RF_fail_bits | |MOTOR_LF_fail_bits |
                   |MOTOR_RB_fail_bits | |MOTOR_LB_fail_bits | |led0_fail_bits;

endmodule

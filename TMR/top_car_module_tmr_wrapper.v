module top_car_module_tmr_wrapper (
    clk,
    enc_a,
    enc_b,
    enc_btn_n,
    dir_switch_r,
    dir_switch_l,
    reed_in,
    MOTOR_RF,
    MOTOR_RB,
    MOTOR_LF,
    MOTOR_LB,
    led0,
    flip_a,
    flip_b,
    flip_c,
    fail_flag
);

input clk;
input enc_a;
input enc_b;
input enc_btn_n;
input dir_switch_r;
input dir_switch_l;
input reed_in;
output [2:0] MOTOR_RF;
output [2:0] MOTOR_RB;
output [2:0] MOTOR_LF;
output [2:0] MOTOR_LB;
output led0;
input flip_a, flip_b, flip_c;
output fail_flag;

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

wire [2:0] MOTOR_RF_a, MOTOR_RF_b, MOTOR_RF_c;
wire [2:0] MOTOR_RB_a, MOTOR_RB_b, MOTOR_RB_c;
wire [2:0] MOTOR_LF_a, MOTOR_LF_b, MOTOR_LF_c;
wire [2:0] MOTOR_LB_a, MOTOR_LB_b, MOTOR_LB_c;
wire led0_a, led0_b, led0_c;

top_car_module u_a (
    .clk(clk_a),
    .enc_a(enc_a_a),
    .enc_b(enc_b_a),
    .enc_btn_n(enc_btn_n_a),
    .dir_switch_r(dir_switch_r_a),
    .dir_switch_l(dir_switch_l_a),
    .reed_in(reed_in_a),
    .MOTOR_RF(MOTOR_RF_a),
    .MOTOR_RB(MOTOR_RB_a),
    .MOTOR_LF(MOTOR_LF_a),
    .MOTOR_LB(MOTOR_LB_a),
    .led0(led0_a)
);

top_car_module u_b (
    .clk(clk_b),
    .enc_a(enc_a_b),
    .enc_b(enc_b_b),
    .enc_btn_n(enc_btn_n_b),
    .dir_switch_r(dir_switch_r_b),
    .dir_switch_l(dir_switch_l_b),
    .reed_in(reed_in_b),
    .MOTOR_RF(MOTOR_RF_b),
    .MOTOR_RB(MOTOR_RB_b),
    .MOTOR_LF(MOTOR_LF_b),
    .MOTOR_LB(MOTOR_LB_b),
    .led0(led0_b)
);

top_car_module u_c (
    .clk(clk_c),
    .enc_a(enc_a_c),
    .enc_b(enc_b_c),
    .enc_btn_n(enc_btn_n_c),
    .dir_switch_r(dir_switch_r_c),
    .dir_switch_l(dir_switch_l_c),
    .reed_in(reed_in_c),
    .MOTOR_RF(MOTOR_RF_c),
    .MOTOR_RB(MOTOR_RB_c),
    .MOTOR_LF(MOTOR_LF_c),
    .MOTOR_LB(MOTOR_LB_c),
    .led0(led0_c)
);

assign MOTOR_RF = (MOTOR_RF_a & MOTOR_RF_b) | (MOTOR_RF_b & MOTOR_RF_c) | (MOTOR_RF_a & MOTOR_RF_c);
wire [2:0] MOTOR_RF_fail_bits = (MOTOR_RF_a ^ MOTOR_RF_b) & (MOTOR_RF_b ^ MOTOR_RF_c);

assign MOTOR_RB = (MOTOR_RB_a & MOTOR_RB_b) | (MOTOR_RB_b & MOTOR_RB_c) | (MOTOR_RB_a & MOTOR_RB_c);
wire [2:0] MOTOR_RB_fail_bits = (MOTOR_RB_a ^ MOTOR_RB_b) & (MOTOR_RB_b ^ MOTOR_RB_c);

assign MOTOR_LF = (MOTOR_LF_a & MOTOR_LF_b) | (MOTOR_LF_b & MOTOR_LF_c) | (MOTOR_LF_a & MOTOR_LF_c);
wire [2:0] MOTOR_LF_fail_bits = (MOTOR_LF_a ^ MOTOR_LF_b) & (MOTOR_LF_b ^ MOTOR_LF_c);

assign MOTOR_LB = (MOTOR_LB_a & MOTOR_LB_b) | (MOTOR_LB_b & MOTOR_LB_c) | (MOTOR_LB_a & MOTOR_LB_c);
wire [2:0] MOTOR_LB_fail_bits = (MOTOR_LB_a ^ MOTOR_LB_b) & (MOTOR_LB_b ^ MOTOR_LB_c);

assign led0 = (led0_a & led0_b) | (led0_b & led0_c) | (led0_a & led0_c);
wire led0_fail_bits = (led0_a ^ led0_b) & (led0_b ^ led0_c);

assign fail_flag = |MOTOR_RF_fail_bits | |MOTOR_RB_fail_bits | |MOTOR_LF_fail_bits | |MOTOR_LB_fail_bits | |led0_fail_bits;

endmodule
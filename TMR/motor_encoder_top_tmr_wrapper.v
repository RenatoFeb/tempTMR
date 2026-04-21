module motor_encoder_top_tmr_wrapper (
    clk,
    rst,
    enc_a,
    enc_b,
    enc_btn_n,
    dir_switch,
    motor_in3,
    motor_in4,
    motor_enb,
    flip_a,
    flip_b,
    flip_c,
    fail_flag
);

input clk;
input rst;
input enc_a;
input enc_b;
input enc_btn_n;
input dir_switch;
output motor_in3;
output motor_in4;
output motor_enb;
input flip_a, flip_b, flip_c;
output fail_flag;

wire clk_a = clk;
wire clk_b = clk;
wire clk_c = clk;

wire rst_a = rst;
wire rst_b = rst;
wire rst_c = rst;

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

wire dir_switch_a, dir_switch_b, dir_switch_c;
assign dir_switch_a = dir_switch ^ {1{flip_a}};
assign dir_switch_b = dir_switch ^ {1{flip_b}};
assign dir_switch_c = dir_switch ^ {1{flip_c}};

wire motor_in3_a, motor_in3_b, motor_in3_c;
wire motor_in4_a, motor_in4_b, motor_in4_c;
wire motor_enb_a, motor_enb_b, motor_enb_c;

motor_encoder_top u_a (
    .clk(clk_a),
    .rst(rst_a),
    .enc_a(enc_a_a),
    .enc_b(enc_b_a),
    .enc_btn_n(enc_btn_n_a),
    .dir_switch(dir_switch_a),
    .motor_in3(motor_in3_a),
    .motor_in4(motor_in4_a),
    .motor_enb(motor_enb_a)
);

motor_encoder_top u_b (
    .clk(clk_b),
    .rst(rst_b),
    .enc_a(enc_a_b),
    .enc_b(enc_b_b),
    .enc_btn_n(enc_btn_n_b),
    .dir_switch(dir_switch_b),
    .motor_in3(motor_in3_b),
    .motor_in4(motor_in4_b),
    .motor_enb(motor_enb_b)
);

motor_encoder_top u_c (
    .clk(clk_c),
    .rst(rst_c),
    .enc_a(enc_a_c),
    .enc_b(enc_b_c),
    .enc_btn_n(enc_btn_n_c),
    .dir_switch(dir_switch_c),
    .motor_in3(motor_in3_c),
    .motor_in4(motor_in4_c),
    .motor_enb(motor_enb_c)
);

assign motor_in3 = (motor_in3_a & motor_in3_b) | (motor_in3_b & motor_in3_c) | (motor_in3_a & motor_in3_c);
wire motor_in3_fail_bits = (motor_in3_a ^ motor_in3_b) & (motor_in3_b ^ motor_in3_c);

assign motor_in4 = (motor_in4_a & motor_in4_b) | (motor_in4_b & motor_in4_c) | (motor_in4_a & motor_in4_c);
wire motor_in4_fail_bits = (motor_in4_a ^ motor_in4_b) & (motor_in4_b ^ motor_in4_c);

assign motor_enb = (motor_enb_a & motor_enb_b) | (motor_enb_b & motor_enb_c) | (motor_enb_a & motor_enb_c);
wire motor_enb_fail_bits = (motor_enb_a ^ motor_enb_b) & (motor_enb_b ^ motor_enb_c);

assign fail_flag = |motor_in3_fail_bits | |motor_in4_fail_bits | |motor_enb_fail_bits;

endmodule
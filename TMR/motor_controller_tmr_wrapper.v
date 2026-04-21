module motor_controller_tmr_wrapper (
    clk,
    rst,
    enable,
    direction,
    speed,
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
input enable;
input direction;
input [12:0] speed;
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

wire enable_a, enable_b, enable_c;
assign enable_a = enable ^ {1{flip_a}};
assign enable_b = enable ^ {1{flip_b}};
assign enable_c = enable ^ {1{flip_c}};

wire direction_a, direction_b, direction_c;
assign direction_a = direction ^ {1{flip_a}};
assign direction_b = direction ^ {1{flip_b}};
assign direction_c = direction ^ {1{flip_c}};

wire [12:0] speed_a, speed_b, speed_c;
assign speed_a = speed ^ {13{flip_a}};
assign speed_b = speed ^ {13{flip_b}};
assign speed_c = speed ^ {13{flip_c}};

wire motor_in3_a, motor_in3_b, motor_in3_c;
wire motor_in4_a, motor_in4_b, motor_in4_c;
wire motor_enb_a, motor_enb_b, motor_enb_c;

motor_controller u_a (
    .clk(clk_a),
    .rst(rst_a),
    .enable(enable_a),
    .direction(direction_a),
    .speed(speed_a),
    .motor_in3(motor_in3_a),
    .motor_in4(motor_in4_a),
    .motor_enb(motor_enb_a)
);

motor_controller u_b (
    .clk(clk_b),
    .rst(rst_b),
    .enable(enable_b),
    .direction(direction_b),
    .speed(speed_b),
    .motor_in3(motor_in3_b),
    .motor_in4(motor_in4_b),
    .motor_enb(motor_enb_b)
);

motor_controller u_c (
    .clk(clk_c),
    .rst(rst_c),
    .enable(enable_c),
    .direction(direction_c),
    .speed(speed_c),
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
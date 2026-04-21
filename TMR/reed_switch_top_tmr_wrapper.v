module reed_switch_top_tmr_wrapper (
    clk,
    reed_in,
    led0,
    flip_a,
    flip_b,
    flip_c,
    fail_flag
);

input clk;
input reed_in;
output led0;
input flip_a, flip_b, flip_c;
output fail_flag;

wire clk_a = clk;
wire clk_b = clk;
wire clk_c = clk;

wire reed_in_a, reed_in_b, reed_in_c;
assign reed_in_a = reed_in ^ {1{flip_a}};
assign reed_in_b = reed_in ^ {1{flip_b}};
assign reed_in_c = reed_in ^ {1{flip_c}};

wire led0_a, led0_b, led0_c;

reed_switch_top u_a (
    .clk(clk_a),
    .reed_in(reed_in_a),
    .led0(led0_a)
);

reed_switch_top u_b (
    .clk(clk_b),
    .reed_in(reed_in_b),
    .led0(led0_b)
);

reed_switch_top u_c (
    .clk(clk_c),
    .reed_in(reed_in_c),
    .led0(led0_c)
);

assign led0 = (led0_a & led0_b) | (led0_b & led0_c) | (led0_a & led0_c);
wire led0_fail_bits = (led0_a ^ led0_b) & (led0_b ^ led0_c);

assign fail_flag = |led0_fail_bits;

endmodule
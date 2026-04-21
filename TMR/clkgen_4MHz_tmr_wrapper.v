module clkgen_4MHz_tmr_wrapper (
    CLK100MHZ,
    clk_4MHz,
    flip_a,
    flip_b,
    flip_c,
    fail_flag
);

input CLK100MHZ;
output clk_4MHz;
input flip_a, flip_b, flip_c;
output fail_flag;

wire CLK100MHZ_a, CLK100MHZ_b, CLK100MHZ_c;
assign CLK100MHZ_a = CLK100MHZ ^ {1{flip_a}};
assign CLK100MHZ_b = CLK100MHZ ^ {1{flip_b}};
assign CLK100MHZ_c = CLK100MHZ ^ {1{flip_c}};

wire clk_4MHz_a, clk_4MHz_b, clk_4MHz_c;

clkgen_4MHz u_a (
    .CLK100MHZ(CLK100MHZ_a),
    .clk_4MHz(clk_4MHz_a)
);

clkgen_4MHz u_b (
    .CLK100MHZ(CLK100MHZ_b),
    .clk_4MHz(clk_4MHz_b)
);

clkgen_4MHz u_c (
    .CLK100MHZ(CLK100MHZ_c),
    .clk_4MHz(clk_4MHz_c)
);

assign clk_4MHz = (clk_4MHz_a & clk_4MHz_b) | (clk_4MHz_b & clk_4MHz_c) | (clk_4MHz_a & clk_4MHz_c);
wire clk_4MHz_fail_bits = (clk_4MHz_a ^ clk_4MHz_b) & (clk_4MHz_b ^ clk_4MHz_c);

assign fail_flag = |clk_4MHz_fail_bits;

endmodule
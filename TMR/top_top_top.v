`timescale 1ns / 1ps

module top_top_top (
    input        reset,
    input  [7:0] temp_data,
    output [6:0] SEG,
    output       DP,
    output [3:0] AN,

    input wire clk,
    input wire enc_a,
    input wire enc_b,
    input wire enc_btn_n,
    input wire dir_switch_r,
    input wire dir_switch_l,
    input wire reed_in,
    output wire [2:0] MOTOR_RF,
    output wire [2:0] MOTOR_LF,
    output wire [2:0] MOTOR_RB,
    output wire [2:0] MOTOR_LB,
    output wire led0
);

    localparam DEBOUNCE_CYCLES = 500000;
    localparam PWM_PERIOD      = 5000;
    localparam MAX_POSITION    = 200;
    localparam MIN_POSITION    = 0;

    top_car_module_tmr_wrapper motor_ctl(
        .clk(clk),
        .enc_a(enc_a),
        .enc_b(enc_b),
        .enc_btn_n(enc_btn_n),
        .dir_switch_r(dir_switch_r),
        .dir_switch_l(dir_switch_l),
        .reed_in(reed_in),
        .MOTOR_RB(MOTOR_RB),
        .MOTOR_LB(MOTOR_LB),
        .MOTOR_RF(MOTOR_RF),
        .MOTOR_LF(MOTOR_LF),
        .led0(led0)
    );

    top_tmr_wrapper TOP (
        .CLK100MHZ(clk),
        .reset(reset),
        .temp_data(temp_data),
        .SEG(SEG),
        .DP(DP),
        .AN(AN)
    );

endmodule

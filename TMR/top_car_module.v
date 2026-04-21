`timescale 1ns / 1ps

module top_car_module(
    input wire clk,
    input wire enc_a,
    input wire enc_b,
    input wire enc_btn_n,
    input wire dir_switch_r,
    input wire dir_switch_l,
    input wire reed_in,
    output wire [2:0] MOTOR_RF,
    output wire [2:0] MOTOR_RB,
    output wire [2:0] MOTOR_LF,
    output wire [2:0] MOTOR_LB,
    output wire led0
    );
    
    localparam  DEBOUNCE_CYCLES = 500000; 
    localparam  PWM_PERIOD = 5000; 
    localparam  MAX_POSITION = 200;      
    localparam  MIN_POSITION = 0;
    
    wire rst = 1'b0;
    wire motor_rf_in3;
    wire motor_rf_in4;
    wire motor_rf_enb;
    
    motor_encoder_top_tmr_wrapper motor_right_front (
        .clk(clk),
        .rst(rst),
        .enc_a(enc_a),
        .enc_b(enc_b),
        .enc_btn_n(enc_btn_n),
        .dir_switch(dir_switch_r),
        .motor_in3(motor_rf_in3),
        .motor_in4(motor_rf_in4),
        .motor_enb(motor_rf_enb)
    );
    
    assign MOTOR_RF[0] = motor_rf_in3;
    assign MOTOR_RF[1] = motor_rf_in4;
    assign MOTOR_RF[2] = motor_rf_enb;
    
    
    wire motor_rb_in1;
    wire motor_rb_in2;
    wire motor_rb_ena;
    
    motor_encoder_top_tmr_wrapper motor_right_back (
        .clk(clk),
        .rst(rst),
        .enc_a(enc_a),
        .enc_b(enc_b),
        .enc_btn_n(enc_btn_n),
        .dir_switch(dir_switch_r),
        .motor_in3(motor_rb_in1),
        .motor_in4(motor_rb_in2),
        .motor_enb(motor_rb_ena)
    );
    
    assign MOTOR_RB[0] = motor_rb_in1;
    assign MOTOR_RB[1] = motor_rb_in2;
    assign MOTOR_RB[2] = motor_rb_ena;
    
    
    wire motor_lf_in1;
    wire motor_lf_in2;
    wire motor_lf_ena;
    
    motor_encoder_top_tmr_wrapper motor_left_front (
        .clk(clk),
        .rst(rst),
        .enc_a(enc_a),
        .enc_b(enc_b),
        .enc_btn_n(enc_btn_n),
        .dir_switch(dir_switch_l),
        .motor_in3(motor_lf_in1),
        .motor_in4(motor_lf_in2),
        .motor_enb(motor_lf_ena)
    );
    
    assign MOTOR_LF[0] = motor_lf_in1;
    assign MOTOR_LF[1] = motor_lf_in2;
    assign MOTOR_LF[2] = motor_lf_ena;
    
    wire motor_lb_in3;
    wire motor_lb_in4;
    wire motor_lb_enb;
    
    motor_encoder_top_tmr_wrapper  motor_left_back (
        .clk(clk),
        .rst(rst),
        .enc_a(enc_a),
        .enc_b(enc_b),
        .enc_btn_n(enc_btn_n),
        .dir_switch(dir_switch_l),
        .motor_in3(motor_lb_in3),
        .motor_in4(motor_lb_in4),
        .motor_enb(motor_lb_enb)
    );
    
    assign MOTOR_LB[0] = motor_lb_in3;
    assign MOTOR_LB[1] = motor_lb_in4;
    assign MOTOR_LB[2] = motor_lb_enb;
    
    reed_switch_top_tmr_wrapper u_reed(
    .clk(clk),
    .reed_in(reed_in),
    .led0(led0)
    );
    
endmodule

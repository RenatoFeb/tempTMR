`timescale 1ns / 1ps

module motor_encoder_top(
    input wire clk,              
    input wire rst,             
   
    
    input wire enc_a,
    input wire enc_b,
    input wire enc_btn_n,
   

    input wire dir_switch,
   
   
    output wire motor_in3,
    output wire motor_in4,
    output wire motor_enb
);

    localparam  DEBOUNCE_CYCLES = 500000; 
    localparam  PWM_PERIOD = 5000; 
    localparam  MAX_POSITION = 200;      
    localparam  MIN_POSITION = 0;

    // Internal signals
    wire signed [15:0] position;
    wire btn_pulse;
    reg motor_enable;  
   
   
    reg[1:0] dir_sync;
    always @ (posedge clk) begin
        dir_sync <= {dir_sync[0], dir_switch};
    end
    wire dir_clean = dir_sync[1];
    
    wire [15:0] abs_position = position[15] ? -position : position;
    
    reg [$clog2(PWM_PERIOD)-1:0] motor_speed;
    
    localparam integer MIN_DUTY = PWM_PERIOD / 4;
   
    quadrature_decoder decoder (
        .clk(clk),
        .rst(rst),
        .enc_a_raw(enc_a),
        .enc_b_raw(enc_b),
        .enc_btn_n_raw(enc_btn_n),
        .position(position),
        .btn_pulse(btn_pulse)
    );
   
    always @(posedge clk) begin
        if (rst)
            motor_enable <= 0; 
        else if (btn_pulse)
            motor_enable <= ~motor_enable;
    end
   
    always @(posedge clk) begin
        if (rst) begin
            motor_speed <= 0;
        end else begin
           
            //  deadband and clamp
            if (abs_position < MIN_POSITION) begin
                motor_speed <= 0;
            end else if (abs_position >= MAX_POSITION) begin
                motor_speed <= PWM_PERIOD -1; 
            end else begin
                motor_speed <= MIN_DUTY + ((abs_position * (PWM_PERIOD -1 - MIN_DUTY)) / MAX_POSITION);
            end
        end
    end
   

    // Instantiate motor controller 
    motor_controller_tmr_wrapper motor_ctrl (
        .clk(clk),
        .rst(rst),
        .enable(motor_enable),
        .direction(dir_clean),
        .speed(motor_speed),
        .motor_in3(motor_in3),
        .motor_in4(motor_in4),
        .motor_enb(motor_enb)
    );

endmodule
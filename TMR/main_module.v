`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module: motor_controller

module motor_controller (
    input wire clk,
    input wire rst,
   
    // Motor control inputs
    input wire enable,                          
    input wire direction,                       
    input wire [$clog2(PERIOD)-1:0] speed,      
   
    // Motor outputs
    output wire motor_in3,
    output wire motor_in4,
    output wire motor_enb
);


    localparam CLK_FREQ = 100_000_000;
    localparam PWM_FREQ = 20_000;  
    localparam PERIOD = CLK_FREQ/PWM_FREQ; 

    // PWM counter (like your original counter)
    reg [$clog2(PERIOD)-1:0] counter;
   
    always @(posedge clk) begin
        if (rst)
            counter <= 0;
        else if (counter < PERIOD - 1)
            counter <= counter + 1;
        else
            counter <= 0;
    end
   
    // PWM output: high when counter < speed (like your original comparison)
    wire pwm_out;
    assign pwm_out = (counter < speed) ? 1'b1 : 1'b0;
   
   
    assign motor_in3 = enable & ~direction;  
    assign motor_in4 = enable & direction;   
    assign motor_enb = enable ? pwm_out : 1'b0;

endmodule
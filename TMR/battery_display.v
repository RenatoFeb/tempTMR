`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/03/2026 01:14:18 PM
// Design Name: 
// Module Name: battery_display
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module battery_display(
    input CLK100MHZ,
    input [23:0] adc_value,

    output reg [6:0] seg,
    output reg dp,
    output reg [7:0] an
);


parameter ADC_MIN = 24'd3000000;  // 
parameter ADC_MAX = 24'd3900000;  //


reg [7:0] percent;

always @(*) begin

    if(adc_value <= ADC_MIN)
        percent = 0;

    else if(adc_value >= ADC_MAX)
        percent = 100;

    else
        percent = ((adc_value - ADC_MIN) * 100) / (ADC_MAX - ADC_MIN);

end


wire [3:0] p100;
wire [3:0] p10;
wire [3:0] p1;

assign p100 = percent / 100;
assign p10  = (percent % 100) / 10;
assign p1   = percent % 10;


parameter ZERO  = 7'b0000001;
parameter ONE   = 7'b1001111;
parameter TWO   = 7'b0010010;
parameter THREE = 7'b0000110;
parameter FOUR  = 7'b1001100;
parameter FIVE  = 7'b0100100;
parameter SIX   = 7'b0100000;
parameter SEVEN = 7'b0001111;
parameter EIGHT = 7'b0000000;
parameter NINE  = 7'b0000100;
parameter PERCENT = 7'b0011000; // crude %

/////////////////////////////////////////////////////////
// Multiplexing
/////////////////////////////////////////////////////////

reg [2:0] an_sel;
reg [16:0] refresh;

always @(posedge CLK100MHZ) begin
    if(refresh == 100000) begin
        refresh <= 0;
        an_sel <= an_sel + 1;
    end
    else
        refresh <= refresh + 1;
end

always @(*) begin
    case(an_sel)

    0: begin
        an = 8'b11101111;
        dp = 1;
        case(p1)
            0: seg = ZERO;
            1: seg = ONE;
            2: seg = TWO;
            3: seg = THREE;
            4: seg = FOUR;
            5: seg = FIVE;
            6: seg = SIX;
            7: seg = SEVEN;
            8: seg = EIGHT;
            9: seg = NINE;
        endcase
    end

    1: begin
        an = 8'b11011111;
        dp = 1;
        case(p10)
            0: seg = ZERO;
            1: seg = ONE;
            2: seg = TWO;
            3: seg = THREE;
            4: seg = FOUR;
            5: seg = FIVE;
            6: seg = SIX;
            7: seg = SEVEN;
            8: seg = EIGHT;
            9: seg = NINE;
        endcase
    end

    2: begin
        an = 8'b10111111;
        dp = 1;
        case(p100)
            0: seg = ZERO;
            1: seg = ONE;
        endcase
    end

    3: begin
        an = 8'b01111111;
        dp = 1;
        seg = PERCENT;
    end

    default: begin
        an = 8'b11111111;
        seg = 7'b1111111;
        dp = 1;
    end

    endcase
end

endmodule

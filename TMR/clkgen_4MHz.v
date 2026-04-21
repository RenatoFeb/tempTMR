`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/03/2026 01:06:50 PM
// Design Name: 
// Module Name: clkgen_4MHz
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


module clkgen_4MHz(
    input CLK100MHZ,
    output reg clk_4MHz
);

reg [4:0] counter;

always @(posedge CLK100MHZ) begin
    counter <= counter + 1;
    clk_4MHz <= counter[4];
end

endmodule

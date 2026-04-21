`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/03/2026 01:13:41 PM
// Design Name: 
// Module Name: mcp3910_ctrl
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


module mcp3910_ctrl(
    input wire clk,

    output reg spi_start,
    output reg [31:0] spi_tx,
    output reg [5:0] spi_bits,
    input wire [31:0] spi_rx,
    input wire spi_done,

    output reg [23:0] adc_data
);

reg [2:0] state;

localparam SEND_CMD = 0;
localparam WAIT_SPI = 1;
localparam STORE = 2;

/////////////////////////////////////////////////////////
// MCP3910 COMMAND
// Example: Read register 0x00
/////////////////////////////////////////////////////////

wire [7:0] read_cmd = {7'h00, 1'b1};

always @(posedge clk) begin

    spi_start <= 0;

    case(state)

    SEND_CMD: begin
        spi_tx <= {read_cmd, 24'h000000};
        spi_bits <= 32;
        spi_start <= 1;
        state <= WAIT_SPI;
    end

    WAIT_SPI: begin
        if(spi_done)
            state <= STORE;
    end

    STORE: begin
        adc_data <= spi_rx[23:0];
        state <= SEND_CMD;
    end

    endcase

end

endmodule
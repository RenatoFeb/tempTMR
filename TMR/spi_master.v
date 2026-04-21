`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/03/2026 01:10:25 PM
// Design Name: 
// Module Name: spi_master
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


module spi_master(
    input wire clk,
    input wire rst,

    input wire start,
    input wire [31:0] tx_data,
    input wire [5:0] bit_count,
    input wire [15:0] clk_div,

    input wire cpol,
    input wire cpha,

    output reg sclk,
    output reg mosi,
    input wire miso,
    output reg cs,

    output reg [31:0] rx_data,
    output reg busy,
    output reg done
);

reg [15:0] clk_cnt;
reg clk_en;

reg [5:0] bit_index;
reg [31:0] tx_shift;
reg [31:0] rx_shift;

reg [1:0] state;

localparam READY = 2'd0;
localparam TRANSFER = 2'd1;
localparam FINISH = 2'd2;

/////////////////////////////////////////////////////////
// Clock divider
/////////////////////////////////////////////////////////

always @(posedge clk or posedge rst) begin
    if (rst) begin
        clk_cnt <= 0;
        clk_en <= 0;
    end else begin
        if (clk_cnt == clk_div) begin
            clk_cnt <= 0;
            clk_en <= 1;
        end else begin
            clk_cnt <= clk_cnt + 1;
            clk_en <= 0;
        end
    end
end

/////////////////////////////////////////////////////////
// SPI FSM
/////////////////////////////////////////////////////////

always @(posedge clk or posedge rst) begin
    if (rst) begin
        state <= READY;
        cs <= 1;
        busy <= 0;
        done <= 0;
        sclk <= 0;
    end else begin

        done <= 0;

        case(state)

        READY: begin
            busy <= 0;
            sclk <= cpol;

            if(start) begin
                busy <= 1;
                cs <= 0;
                tx_shift <= tx_data;
                rx_shift <= 0;
                bit_index <= bit_count - 1;
                state <= TRANSFER;
            end
        end

        TRANSFER: begin
            if(clk_en) begin
                sclk <= ~sclk;

                if(sclk == cpha) begin
                    mosi <= tx_shift[bit_index];
                end else begin
                    rx_shift[bit_index] <= miso;

                    if(bit_index == 0)
                        state <= FINISH;
                    else
                        bit_index <= bit_index - 1;
                end
            end
        end

        FINISH: begin
            cs <= 1;
            busy <= 0;
            done <= 1;
            rx_data <= rx_shift;
            state <= READY;
        end

        endcase
    end
end

endmodule



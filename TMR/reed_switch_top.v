`timescale 1ns / 1ps


module reed_switch_top(
    input wire clk,
    input wire reed_in,
    output wire led0
    );
    
    //2-flop synchronizer
    reg s1=1'b1, s2=1'b1;
    always @(posedge clk) begin
        s1 <= reed_in;
        s2 <= s1;
    end
    
    //debounce
    localparam integer DB_MAX = 500_000;
    reg [19:0] db_cnt = 0;
    reg db_state = 1'b1;
    
    always @(posedge clk) begin
        if (s2 == db_state) begin
            db_cnt <= 0;
        end else begin
            if (db_cnt == DB_MAX-1) begin
                db_state <= s2;
                db_cnt <= 0;
            end else begin
                db_cnt <= db_cnt + 1;
            end
        end
    end
    
    assign led0 = db_state;
    
    
endmodule
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module: quadrature_decoder

module quadrature_decoder(
    input wire clk,
    input wire rst,
   
    // Encoder inputs 
    input wire enc_a_raw,
    input wire enc_b_raw,
    input wire enc_btn_n_raw, 
   
    // Outputs
    output reg signed [15:0] position, 
    output reg btn_pulse              
);

    localparam DEBOUNCE_CYCLES = 500000;  


    // Synchronizer chains
    reg [1:0] sync_a, sync_b, sync_btn;
   
    always @(posedge clk) begin
        sync_a <= {sync_a[0], enc_a_raw};
        sync_b <= {sync_b[0], enc_b_raw};
        sync_btn <= {sync_btn[0], ~enc_btn_n_raw}; 
    end
   
    wire enc_a_sync = sync_a[1];
    wire enc_b_sync = sync_b[1];
    wire enc_btn_sync = sync_btn[1];
   
    // Debounce counters for A, B, and button
    reg [$clog2(DEBOUNCE_CYCLES)-1:0] debounce_cnt_a, debounce_cnt_b, debounce_cnt_btn;
    reg enc_a_stable, enc_b_stable, enc_btn_stable;
    reg enc_a_state, enc_b_state, enc_btn_state;
   
    // Debounce A
    always @(posedge clk) begin
        if (rst) begin
            debounce_cnt_a <= 0;
            enc_a_stable <= 0;
            enc_a_state <= 0;
        end else begin
            if (enc_a_sync != enc_a_state) begin
                if (debounce_cnt_a == DEBOUNCE_CYCLES - 1) begin
                    enc_a_state <= enc_a_sync;
                    enc_a_stable <= 1;
                    debounce_cnt_a <= 0;
                end else begin
                    debounce_cnt_a <= debounce_cnt_a + 1;
                    enc_a_stable <= 0;
                end
            end else begin
                debounce_cnt_a <= 0;
                enc_a_stable <= 0;
            end
        end
    end
   
    // Debounce B
    always @(posedge clk) begin
        if (rst) begin
            debounce_cnt_b <= 0;
            enc_b_stable <= 0;
            enc_b_state <= 0;
        end else begin
            if (enc_b_sync != enc_b_state) begin
                if (debounce_cnt_b == DEBOUNCE_CYCLES - 1) begin
                    enc_b_state <= enc_b_sync;
                    enc_b_stable <= 1;
                    debounce_cnt_b <= 0;
                end else begin
                    debounce_cnt_b <= debounce_cnt_b + 1;
                    enc_b_stable <= 0;
                end
            end else begin
                debounce_cnt_b <= 0;
                enc_b_stable <= 0;
            end
        end
    end
   
    // Debounce button
    always @(posedge clk) begin
        if (rst) begin
            debounce_cnt_btn <= 0;
            enc_btn_stable <= 0;
            enc_btn_state <= 0;
        end else begin
            if (enc_btn_sync != enc_btn_state) begin
                if (debounce_cnt_btn == DEBOUNCE_CYCLES - 1) begin
                    enc_btn_state <= enc_btn_sync;
                    enc_btn_stable <= 1;
                    debounce_cnt_btn <= 0;
                end else begin
                    debounce_cnt_btn <= debounce_cnt_btn + 1;
                    enc_btn_stable <= 0;
                end
            end else begin
                debounce_cnt_btn <= 0;
                enc_btn_stable <= 0;
            end
        end
    end
   
    // Quadrature decoding state machine
    reg [1:0] ab_prev;
    wire [1:0] ab_curr = {enc_a_state, enc_b_state};
   
    always @(posedge clk) begin
        if (rst) begin
            position <= 16'sd0;
            ab_prev <= 2'b00;
        end else begin
            if (enc_a_stable || enc_b_stable) begin
                case ({ab_prev, ab_curr})
                    // Clockwise transitions
                    4'b0001, 4'b0111, 4'b1110, 4'b1000: position <= position + 1;
                    // Counter-clockwise transitions
                    4'b0010, 4'b1011, 4'b1101, 4'b0100: position <= position - 1;
                    // All other transitions: ignore
                    default: ;
                endcase
                ab_prev <= ab_curr;
            end
        end
    end
   
    // Button press detector (rising edge = single pulse)
    reg enc_btn_prev;
   
    always @(posedge clk) begin
        if (rst) begin
            enc_btn_prev <= 0;
            btn_pulse <= 0;
        end else begin
            enc_btn_prev <= enc_btn_state;
            btn_pulse <= enc_btn_stable && enc_btn_state && ~enc_btn_prev;
        end
    end

endmodule

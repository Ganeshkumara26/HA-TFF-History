`timescale 1ns / 1ps

module ha_tff_matcher (
    input  wire         clk,
    input  wire         rst,
    
    input  wire [103:0] tuple_in,
    input  wire         valid_in,
    
    // BRAM data inputs (from 4 banks)
    input  wire [127:0] b0_data,
    input  wire [127:0] b1_data,
    input  wire [127:0] b2_data,
    input  wire [127:0] b3_data,
    input  wire         bram_valid,
    
    // Outputs
    output reg          match_found,
    output reg          action_forward,
    output reg          match_valid
);

    // We must pipeline the tuple_in to match the BRAM latency.
    // The hash takes 1 cycle, BRAM takes 2 cycles.
    // Total delay = 3 cycles.
    reg [103:0] tuple_delay [0:2];
    reg         valid_delay [0:2];
    
    integer i;

    always @(posedge clk) begin
        if (rst) begin
            for (i=0; i<3; i=i+1) begin
                tuple_delay[i] <= 0;
                valid_delay[i] <= 0;
            end
            match_found    <= 0;
            action_forward <= 0;
            match_valid    <= 0;
        end else begin
            tuple_delay[0] <= tuple_in;
            valid_delay[0] <= valid_in;
            
            tuple_delay[1] <= tuple_delay[0];
            valid_delay[1] <= valid_delay[0];
            
            tuple_delay[2] <= tuple_delay[1];
            valid_delay[2] <= valid_delay[1];
            
            match_valid <= 0;
            
            if (bram_valid && valid_delay[2]) begin
                match_valid <= 1;
                match_found <= 1;
                
                // b_data format:
                // [127] Valid
                // [126] Action (0=Drop, 1=Forward)
                // [103:0] Tuple
                
                if (b0_data[127] && (b0_data[103:0] == tuple_delay[2])) begin
                    action_forward <= b0_data[126];
                end 
                else if (b1_data[127] && (b1_data[103:0] == tuple_delay[2])) begin
                    action_forward <= b1_data[126];
                end
                else if (b2_data[127] && (b2_data[103:0] == tuple_delay[2])) begin
                    action_forward <= b2_data[126];
                end
                else if (b3_data[127] && (b3_data[103:0] == tuple_delay[2])) begin
                    action_forward <= b3_data[126];
                end
                else begin
                    match_found <= 0;
                    action_forward <= 0; // Default Drop if not found
                end
            end
        end
    end

endmodule

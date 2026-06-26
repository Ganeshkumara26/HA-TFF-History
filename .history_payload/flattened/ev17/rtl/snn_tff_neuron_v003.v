`timescale 1ns / 1ps

// Hardware-Efficient Leaky Integrate-and-Fire (LIF) Neuron (v003)
// BUG-004 Fix: Parameter THRESHOLD must be signed to prevent unsigned cast of negative potentials.

module snn_tff_neuron_v003 #(
    parameter DATA_WIDTH = 16,
    parameter LEAK_SHIFT = 3,       
    parameter signed [15:0] THRESHOLD  = 16'sd1000  // Increased threshold to test temporal integration
) (
    input  wire                   clk,
    input  wire                   rst,
    
    input  wire signed [DATA_WIDTH-1:0] syn_current, // I[t]
    input  wire                   valid_in,
    
    output reg                    spike_out
);

    reg signed [DATA_WIDTH-1:0] membrane_u;
    
    wire signed [DATA_WIDTH-1:0] leak_amount = membrane_u >>> LEAK_SHIFT;
    wire signed [DATA_WIDTH-1:0] u_decayed   = membrane_u - leak_amount;
    
    wire signed [DATA_WIDTH-1:0] syn_input   = valid_in ? syn_current : 0;
    wire signed [DATA_WIDTH-1:0] u_temp      = u_decayed + syn_input;

    always @(posedge clk) begin
        if (rst) begin
            membrane_u <= 0;
            spike_out  <= 0;
        end else begin
            // Explicit signed comparison
            if (u_temp >= THRESHOLD) begin
                spike_out  <= 1'b1;
                membrane_u <= 0; // Hard reset to resting potential (0)
            end else begin
                spike_out  <= 1'b0;
                // Prevent negative divergence (floor at resting potential -1000 roughly)
                if (u_temp < -16'sd2000) begin
                    membrane_u <= -16'sd2000;
                end else begin
                    membrane_u <= u_temp;
                end
            end
        end
    end

endmodule

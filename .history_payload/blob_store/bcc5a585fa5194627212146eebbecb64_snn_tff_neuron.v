`timescale 1ns / 1ps

// Hardware-Efficient Leaky Integrate-and-Fire (LIF) Neuron
// Uses a bit-shift leak to avoid DSP multipliers.
//
// Equation: U[t] = U[t-1] - (U[t-1] >> LEAK_SHIFT) + I[t]
// If U[t] >= THRESHOLD, Spike = 1 and U[t] = 0.

module snn_tff_neuron #(
    parameter DATA_WIDTH = 16,
    parameter LEAK_SHIFT = 3,       // alpha approx 0.875
    parameter THRESHOLD  = 16'd500  // Firing threshold
) (
    input  wire                   clk,
    input  wire                   rst,
    
    input  wire signed [DATA_WIDTH-1:0] syn_current, // I[t]
    input  wire                   valid_in,
    
    output reg                    spike_out,
    output reg                    valid_out
);

    reg signed [DATA_WIDTH-1:0] membrane_u;
    
    wire signed [DATA_WIDTH-1:0] leak_amount = membrane_u >>> LEAK_SHIFT;
    wire signed [DATA_WIDTH-1:0] u_decayed   = membrane_u - leak_amount;
    wire signed [DATA_WIDTH-1:0] u_temp      = u_decayed + syn_current;

    always @(posedge clk) begin
        if (rst) begin
            membrane_u <= 0;
            spike_out  <= 0;
            valid_out  <= 0;
        end else begin
            valid_out <= valid_in;
            
            if (valid_in) begin
                if (u_temp >= THRESHOLD) begin
                    spike_out  <= 1'b1;
                    membrane_u <= 0; // Hard reset to resting potential (0)
                end else begin
                    spike_out  <= 1'b0;
                    membrane_u <= u_temp;
                end
            end else begin
                spike_out <= 1'b0;
                // Leak still happens even if no new valid synaptic current? 
                // Usually for clock-driven SNNs, valid_in serves as a clock tick for the SNN layer.
                // If valid_in is 0, the SNN is paused.
            end
        end
    end

endmodule

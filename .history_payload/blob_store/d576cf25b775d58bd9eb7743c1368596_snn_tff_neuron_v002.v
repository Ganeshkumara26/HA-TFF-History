`timescale 1ns / 1ps

// Hardware-Efficient Leaky Integrate-and-Fire (LIF) Neuron (v002)
// BUG-003 Fix: Leak applies every clock cycle, not just on valid_in.

module snn_tff_neuron_v002 #(
    parameter DATA_WIDTH = 16,
    parameter LEAK_SHIFT = 3,       // alpha approx 0.875
    parameter THRESHOLD  = 16'd500  // Firing threshold
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
    
    // Only apply synaptic current if valid_in is high. Otherwise, just leak.
    wire signed [DATA_WIDTH-1:0] syn_input   = valid_in ? syn_current : 0;
    wire signed [DATA_WIDTH-1:0] u_temp      = u_decayed + syn_input;

    always @(posedge clk) begin
        if (rst) begin
            membrane_u <= 0;
            spike_out  <= 0;
        end else begin
            if (u_temp >= THRESHOLD) begin
                spike_out  <= 1'b1;
                membrane_u <= 0; // Hard reset to resting potential (0)
            end else begin
                spike_out  <= 1'b0;
                membrane_u <= u_temp;
            end
        end
    end

endmodule

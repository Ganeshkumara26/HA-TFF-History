`timescale 1ns / 1ps

// Spike-Based Traffic Filter Firewall (SNN-TFF)
// Prototype Fully Connected Spiking Layer (8 inputs -> 2 outputs)

module snn_tff_layer (
    input  wire         clk,
    input  wire         rst,
    
    input  wire [7:0]   in_spikes,
    input  wire         valid_in,
    
    output wire [1:0]   out_spikes,
    output wire         valid_out
);

    // Hardcoded weights for the prototype to avoid complex BRAM fetching
    // Weights are signed 16-bit integers
    // Neuron 0 (Safe Predictor): Excited by regular traffic features (e.g. port 80, standard length)
    wire signed [15:0] w0 [0:7];
    assign w0[0] = 16'd50;
    assign w0[1] = 16'd20;
    assign w0[2] = 16'd0;
    assign w0[3] = 16'd10;
    assign w0[4] = -16'd100; // Penalize anomaly feature
    assign w0[5] = -16'd50;
    assign w0[6] = 16'd30;
    assign w0[7] = 16'd40;

    // Neuron 1 (Anomaly Predictor): Excited by malicious features (e.g. rapid SYN, strange ports, fragmentation)
    wire signed [15:0] w1 [0:7];
    assign w1[0] = -16'd40;
    assign w1[1] = -16'd20;
    assign w1[2] = 16'd150; // Highly excited by anomaly feature 2
    assign w1[3] = 16'd80;
    assign w1[4] = 16'd120;
    assign w1[5] = 16'd60;
    assign w1[6] = -16'd30;
    assign w1[7] = 16'd50;

    // Combinatorial Synaptic Integration (Dot Product of Spikes * Weights)
    // Since inputs are binary spikes, this is just a conditional adder tree!
    reg signed [15:0] current_n0;
    reg signed [15:0] current_n1;
    
    integer i;
    always @(*) begin
        current_n0 = 0;
        current_n1 = 0;
        for (i = 0; i < 8; i = i + 1) begin
            if (in_spikes[i]) begin
                current_n0 = current_n0 + w0[i];
                current_n1 = current_n1 + w1[i];
            end
        end
    end

    // Pipeline stage for Synaptic Integration to meet timing
    reg signed [15:0] current_n0_reg;
    reg signed [15:0] current_n1_reg;
    reg               valid_reg;

    always @(posedge clk) begin
        if (rst) begin
            current_n0_reg <= 0;
            current_n1_reg <= 0;
            valid_reg      <= 0;
        end else begin
            valid_reg <= valid_in;
            if (valid_in) begin
                current_n0_reg <= current_n0;
                current_n1_reg <= current_n1;
            end
        end
    end

    // Instantiate LIF Neurons
    wire valid_n0, valid_n1;
    
    snn_tff_neuron #(
        .DATA_WIDTH(16),
        .LEAK_SHIFT(3),      // Alpha ~0.875
        .THRESHOLD(16'd300)  // Needs a few spikes to fire
    ) neuron_safe (
        .clk(clk),
        .rst(rst),
        .syn_current(current_n0_reg),
        .valid_in(valid_reg),
        .spike_out(out_spikes[0]),
        .valid_out(valid_n0)
    );

    snn_tff_neuron #(
        .DATA_WIDTH(16),
        .LEAK_SHIFT(3),
        .THRESHOLD(16'd300)
    ) neuron_anomaly (
        .clk(clk),
        .rst(rst),
        .syn_current(current_n1_reg),
        .valid_in(valid_reg),
        .spike_out(out_spikes[1]),
        .valid_out(valid_n1)
    );
    
    assign valid_out = valid_n0; // Both neurons share the same pipeline depth

endmodule

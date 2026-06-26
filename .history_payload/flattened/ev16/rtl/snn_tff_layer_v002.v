`timescale 1ns / 1ps

// Spike-Based Traffic Filter Firewall (SNN-TFF) v002
// Prototype Fully Connected Spiking Layer (8 inputs -> 2 outputs)
// Fixes BUG-003

module snn_tff_layer_v002 (
    input  wire         clk,
    input  wire         rst,
    
    input  wire [7:0]   in_spikes,
    input  wire         valid_in,
    
    output wire [1:0]   out_spikes,
    output reg          valid_out // Valid pulse when spikes are evaluated
);

    wire signed [15:0] w0 [0:7];
    assign w0[0] = 16'd50;
    assign w0[1] = 16'd20;
    assign w0[2] = 16'd0;
    assign w0[3] = 16'd10;
    assign w0[4] = -16'd100; 
    assign w0[5] = -16'd50;
    assign w0[6] = 16'd30;
    assign w0[7] = 16'd40;

    wire signed [15:0] w1 [0:7];
    assign w1[0] = -16'd40;
    assign w1[1] = -16'd20;
    assign w1[2] = 16'd150; 
    assign w1[3] = 16'd80;
    assign w1[4] = 16'd120;
    assign w1[5] = 16'd60;
    assign w1[6] = -16'd30;
    assign w1[7] = 16'd50;

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

    reg signed [15:0] current_n0_reg;
    reg signed [15:0] current_n1_reg;
    reg               valid_reg;

    always @(posedge clk) begin
        if (rst) begin
            current_n0_reg <= 0;
            current_n1_reg <= 0;
            valid_reg      <= 0;
            valid_out      <= 0;
        end else begin
            valid_reg <= valid_in;
            valid_out <= valid_reg; // Pipeline delay for validation signal
            if (valid_in) begin
                current_n0_reg <= current_n0;
                current_n1_reg <= current_n1;
            end else begin
                // Force current to 0 when invalid to allow pure leak
                current_n0_reg <= 0;
                current_n1_reg <= 0;
            end
        end
    end

    // The neurons now evaluate continuously and leak every cycle
    snn_tff_neuron_v002 #(
        .DATA_WIDTH(16),
        .LEAK_SHIFT(3),      
        .THRESHOLD(16'd300)  
    ) neuron_safe (
        .clk(clk),
        .rst(rst),
        .syn_current(current_n0_reg),
        .valid_in(valid_reg), // Tells neuron if current is valid
        .spike_out(out_spikes[0])
    );

    snn_tff_neuron_v002 #(
        .DATA_WIDTH(16),
        .LEAK_SHIFT(3),
        .THRESHOLD(16'd300)
    ) neuron_anomaly (
        .clk(clk),
        .rst(rst),
        .syn_current(current_n1_reg),
        .valid_in(valid_reg),
        .spike_out(out_spikes[1])
    );

endmodule

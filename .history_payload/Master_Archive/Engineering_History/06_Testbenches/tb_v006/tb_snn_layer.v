`timescale 1ns / 1ps

module tb_snn_layer;

    reg clk;
    reg rst;
    
    reg [7:0] in_spikes;
    reg       valid_in;
    
    wire [1:0] out_spikes;
    wire       valid_out;

    snn_tff_layer uut (
        .clk(clk),
        .rst(rst),
        .in_spikes(in_spikes),
        .valid_in(valid_in),
        .out_spikes(out_spikes),
        .valid_out(valid_out)
    );

    initial begin
        $dumpfile("tb_snn_layer.vcd");
        $dumpvars(0, tb_snn_layer);
        clk = 0;
        forever #3.2 clk = ~clk; // 156.25 MHz
    end
    
    always @(posedge clk) begin
        if (valid_out) begin
            if (out_spikes[0]) $display("[%0t] SNN FIRED: Safe Traffic Detected", $time);
            if (out_spikes[1]) $display("[%0t] SNN FIRED: Anomaly/Threat Detected (DROP)", $time);
        end
    end

    // Helper task to inject a spike train over N cycles
    task inject_spikes(input [7:0] pattern, input integer cycles);
        integer i;
        begin
            for (i=0; i<cycles; i=i+1) begin
                @(posedge clk);
                valid_in <= 1;
                in_spikes <= pattern;
            end
            @(posedge clk);
            valid_in <= 0;
            in_spikes <= 0;
        end
    endtask

    initial begin
        rst = 1;
        valid_in = 0;
        in_spikes = 0;
        
        #100;
        rst = 0;
        #20;
        
        $display("[%0t] Experiment 1: Normal Traffic Pattern (Excites Safe Neuron)", $time);
        // Pattern with bits 0, 1, 6, 7 active (strong weights for N0)
        inject_spikes(8'b11000011, 8); // 8 consecutive cycles
        
        #100;
        
        $display("[%0t] Experiment 2: Anomaly Traffic Pattern (Excites Anomaly Neuron)", $time);
        // Pattern with bits 2, 3, 4, 5 active (strong weights for N1)
        inject_spikes(8'b00111100, 10);
        
        #100;
        
        $display("[%0t] Experiment 3: Low-rate Anomaly (Should leak and not fire)", $time);
        // Pattern with bits 2, 3, 4 active, but interleaved with zeros to test the LEAK function.
        // If we inject sparsely, the leak should prevent firing.
        inject_spikes(8'b00011100, 1);
        #30; // Wait and leak
        inject_spikes(8'b00011100, 1);
        #30;
        inject_spikes(8'b00011100, 1);
        #30;
        inject_spikes(8'b00011100, 1);
        
        #200;
        $finish;
    end

endmodule

`timescale 1ns / 1ps

module tb_snn_layer_v003;

    reg clk;
    reg rst;
    
    reg [7:0] in_spikes;
    reg       valid_in;
    
    wire [1:0] out_spikes;
    wire       valid_out;

    snn_tff_layer_v003 uut (
        .clk(clk),
        .rst(rst),
        .in_spikes(in_spikes),
        .valid_in(valid_in),
        .out_spikes(out_spikes),
        .valid_out(valid_out)
    );

    initial begin
        $dumpfile("tb_snn_layer_v003.vcd");
        $dumpvars(0, tb_snn_layer_v003);
        clk = 0;
        forever #3.2 clk = ~clk; // 156.25 MHz
    end
    
    always @(posedge clk) begin
        if (valid_out) begin
            if (out_spikes[0]) $display("[%0t] SNN FIRED: Safe Traffic Detected", $time);
            if (out_spikes[1]) $display("[%0t] SNN FIRED: Anomaly/Threat Detected (DROP)", $time);
        end
    end

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
        // Safe neuron max sum is 150. Threshold is 1000. Needs roughly 7-8 cycles of continuous input to fire.
        inject_spikes(8'b11000011, 20); 
        
        #150;
        
        $display("[%0t] Experiment 2: Anomaly Traffic Pattern (Excites Anomaly Neuron)", $time);
        // Anomaly neuron max sum is 410. Threshold is 1000. Needs roughly 3 cycles to fire.
        inject_spikes(8'b00111100, 15);
        
        #150;
        
        $display("[%0t] Experiment 3: Low-rate Anomaly (Should leak and not fire, testing BUG-004 fix)", $time);
        // We inject 1 spike (sum=410), then wait 5 cycles. Leak should reduce it heavily.
        // It should never reach 1000.
        inject_spikes(8'b00111100, 1);
        #32; 
        inject_spikes(8'b00111100, 1);
        #32;
        inject_spikes(8'b00111100, 1);
        #32;
        inject_spikes(8'b00111100, 1);
        #32;
        inject_spikes(8'b00111100, 1);
        
        #200;
        $finish;
    end

endmodule

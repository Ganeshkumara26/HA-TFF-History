`timescale 1ns / 1ps

module tb_ha_tff_hash_v001;

    reg clk;
    reg rst;
    
    reg [103:0] tuple_in;
    reg         valid_in;
    
    wire [11:0] hash_0;
    wire [11:0] hash_1;
    wire [11:0] hash_2;
    wire [11:0] hash_3;
    wire        valid_out;

    ha_tff_hash_v001 uut (
        .clk(clk),
        .rst(rst),
        .tuple_in(tuple_in),
        .valid_in(valid_in),
        .hash_0(hash_0),
        .hash_1(hash_1),
        .hash_2(hash_2),
        .hash_3(hash_3),
        .valid_out(valid_out)
    );

    initial begin
        $dumpfile("tb_ha_tff_hash_v001.vcd");
        $dumpvars(0, tb_ha_tff_hash_v001);
        clk = 0;
        forever #3.2 clk = ~clk; // 156.25 MHz
    end

    always @(posedge clk) begin
        if (valid_out) begin
            $display("[%0t] Hash Computed! Tuple: %x", $time, tuple_in);
            $display("  H0: %x, H1: %x, H2: %x, H3: %x", hash_0, hash_1, hash_2, hash_3);
        end
    end

    task test_tuple(input [103:0] din);
        begin
            @(posedge clk);
            valid_in <= 1;
            tuple_in <= din;
            @(posedge clk);
            valid_in <= 0;
            // Wait for pipeline
            @(posedge clk);
            @(posedge clk);
        end
    endtask

    initial begin
        rst = 1;
        valid_in = 0;
        tuple_in = 0;
        
        #100;
        rst = 0;
        #20;
        
        // Test 1: All zeros
        test_tuple(104'h0);
        
        // Test 2: Sequential
        test_tuple(104'h0102030405060708090A0B0C0D);
        
        // Test 3: Random IP/Port combo
        // Src IP: 192.168.1.1 (C0A80101), Dst: 10.0.0.1 (0A000001)
        // Src Port: 1234 (04D2), Dst Port: 80 (0050), Proto: UDP (11)
        test_tuple({32'hC0A80101, 32'h0A000001, 16'h04D2, 16'h0050, 8'h11});
        
        // Test 4: Slight variation (Port 81)
        test_tuple({32'hC0A80101, 32'h0A000001, 16'h04D2, 16'h0051, 8'h11});
        
        #100;
        $finish;
    end

endmodule

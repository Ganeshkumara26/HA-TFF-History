`timescale 1ns / 1ps

module tb_ha_tff_datapath_top;

    reg clk;
    reg rst;
    
    reg [63:0] s_axis_tdata;
    reg [7:0]  s_axis_tkeep;
    reg s_axis_tvalid;
    reg s_axis_tlast;
    wire s_axis_tready;
    
    wire match_valid;
    wire match_found;
    wire action_forward;
    wire parse_error;

    ha_tff_datapath_top uut (
        .clk(clk),
        .rst(rst),
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tkeep(s_axis_tkeep),
        .s_axis_tvalid(s_axis_tvalid),
        .s_axis_tlast(s_axis_tlast),
        .s_axis_tready(s_axis_tready),
        .match_valid(match_valid),
        .match_found(match_found),
        .action_forward(action_forward),
        .parse_error(parse_error)
    );

    initial begin
        $dumpfile("tb_ha_tff_datapath_top.vcd");
        $dumpvars(0, tb_ha_tff_datapath_top);
        clk = 0;
        forever #3.2 clk = ~clk; // ~156.25 MHz
    end
    
    always @(posedge clk) begin
        if (match_valid) begin
            $display("[%0t] DATAPATH MATCH RESULT:", $time);
            $display("  Found: %b, Action: %b (1=Forward, 0=Drop)", match_found, action_forward);
        end
        if (parse_error) begin
            $display("[%0t] ERROR: Parse Error asserted!", $time);
        end
    end

    task send_word(input [63:0] data, input [7:0] keep, input is_last);
        begin
            @(posedge clk);
            s_axis_tvalid <= 1;
            s_axis_tdata <= data;
            s_axis_tkeep <= keep;
            s_axis_tlast <= is_last;
        end
    endtask

    initial begin
        rst = 1;
        s_axis_tvalid = 0;
        s_axis_tdata = 0;
        s_axis_tkeep = 0;
        s_axis_tlast = 0;
        
        #100;
        rst = 0;
        #20;
        
        $display("[%0t] Sending Packet 1: Known Forward Rule (192.168.1.1 -> 10.0.0.1 : 80)", $time);
        send_word(64'hFFFFFFFFFFFFEEEE, 8'hFF, 0); // Word 0
        send_word(64'hEEEEEEEE08004500, 8'hFF, 0); // Word 1
        send_word(64'h0028ABCD40004011, 8'hFF, 0); // Word 2
        send_word(64'h0000C0A801010A00, 8'hFF, 0); // Word 3 (Src: C0A80101, Dst: 0A00...)
        send_word(64'h000104D200500008, 8'hFF, 0); // Word 4 (...0001, SrcP: 04D2, DstP: 0050)
        send_word(64'hDEADBEEF00000000, 8'hF0, 1); // Word 5 (Payload + last)
        @(posedge clk);
        s_axis_tvalid <= 0;
        s_axis_tlast <= 0;
        
        #100;
        
        $display("[%0t] Sending Packet 2: Known Drop Rule (192.168.1.1 -> 10.0.0.1 : 81)", $time);
        send_word(64'hFFFFFFFFFFFFEEEE, 8'hFF, 0);
        send_word(64'hEEEEEEEE08004500, 8'hFF, 0);
        send_word(64'h0028ABCD40004011, 8'hFF, 0);
        send_word(64'h0000C0A801010A00, 8'hFF, 0);
        send_word(64'h000104D200510008, 8'hFF, 0); // DstP: 0051
        send_word(64'hDEADBEEF00000000, 8'hF0, 1);
        @(posedge clk);
        s_axis_tvalid <= 0;
        s_axis_tlast <= 0;
        
        #100;
        
        $display("[%0t] Sending Packet 3: Unknown Rule (Default Drop)", $time);
        send_word(64'hFFFFFFFFFFFFEEEE, 8'hFF, 0);
        send_word(64'hEEEEEEEE08004500, 8'hFF, 0);
        send_word(64'h0028ABCD40004011, 8'hFF, 0);
        send_word(64'h0000888888880A00, 8'hFF, 0); // Src IP modified to 88.88.88.88
        send_word(64'h000104D200500008, 8'hFF, 0); 
        send_word(64'hDEADBEEF00000000, 8'hF0, 1);
        @(posedge clk);
        s_axis_tvalid <= 0;
        s_axis_tlast <= 0;
        
        #100;
        $finish;
    end

endmodule

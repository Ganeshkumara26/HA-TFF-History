`timescale 1ns / 1ps

module tb_ha_tff_parser_v002;

    reg clk;
    reg rst;
    
    reg [63:0] s_axis_tdata;
    reg [7:0]  s_axis_tkeep;
    reg s_axis_tvalid;
    reg s_axis_tlast;
    wire s_axis_tready;
    
    wire [31:0] src_ip;
    wire [31:0] dst_ip;
    wire [15:0] src_port;
    wire [15:0] dst_port;
    wire [7:0]  protocol;
    wire tuple_valid;
    wire parse_error;

    ha_tff_parser_v002 uut (
        .clk(clk),
        .rst(rst),
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tkeep(s_axis_tkeep),
        .s_axis_tvalid(s_axis_tvalid),
        .s_axis_tlast(s_axis_tlast),
        .s_axis_tready(s_axis_tready),
        .src_ip(src_ip),
        .dst_ip(dst_ip),
        .src_port(src_port),
        .dst_port(dst_port),
        .protocol(protocol),
        .tuple_valid(tuple_valid),
        .parse_error(parse_error)
    );

    initial begin
        $dumpfile("tb_ha_tff_parser_v002.vcd");
        $dumpvars(0, tb_ha_tff_parser_v002);
        clk = 0;
        forever #3.2 clk = ~clk; // ~156.25 MHz
    end

    reg success_flag;
    initial success_flag = 0;

    always @(posedge clk) begin
        if (tuple_valid) begin
            success_flag <= 1;
            $display("[%0t] SUCCESS: Tuple Valid asserted!", $time);
            $display("Src IP: %h, Dst IP: %h", src_ip, dst_ip);
            $display("Src Port: %h, Dst Port: %h, Proto: %h", src_port, dst_port, protocol);
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
        
        $display("[%0t] Sending Valid UDP Packet (64-bit)...", $time);
        
        // Word 0 (Bytes 0-7): Dst MAC [0-5], Src MAC [0-1]
        // Dst MAC: FF FF FF FF FF FF
        // Src MAC: EE EE
        send_word(64'hFFFFFFFFFFFFEEEE, 8'hFF, 0);
        
        // Word 1 (Bytes 8-15): Src MAC [2-5], EtherType, IPv4 Ver/IHL, TOS
        // Src MAC: EE EE EE EE
        // EtherType: 0800
        // Ver/IHL: 45, TOS: 00
        send_word(64'hEEEEEEEE08004500, 8'hFF, 0);
        
        // Word 2 (Bytes 16-23): IPv4 Len, ID, Flags/Frag, TTL, Protocol
        // Len: 0028, ID: ABCD, Flags/Frag: 4000, TTL: 40, Protocol: 11 (UDP)
        send_word(64'h0028ABCD40004011, 8'hFF, 0);
        
        // Word 3 (Bytes 24-31): IPv4 CS, Src IP, Dst IP [0-1]
        // CS: 0000, Src IP: C0A80164, Dst IP[0:1]: 0A00
        send_word(64'h0000C0A801640A00, 8'hFF, 0);
        
        // Word 4 (Bytes 32-39): Dst IP [2-3], Src Port, Dst Port, UDP Len
        // Dst IP[2:3]: 0005, Src Port: 04D2, Dst Port: 0050, UDP Len: 0008
        send_word(64'h000504D200500008, 8'hFF, 0);
        
        // Word 5: Payload + tlast
        send_word(64'hDEADBEEF00000000, 8'hF0, 1);
        
        @(posedge clk);
        s_axis_tvalid <= 0;
        s_axis_tlast <= 0;
        
        #100;
        
        if (!success_flag) begin
            $display("[%0t] ERROR: Test Finished but tuple_valid was never asserted!", $time);
        end
        
        #10;
        $finish;
    end

endmodule

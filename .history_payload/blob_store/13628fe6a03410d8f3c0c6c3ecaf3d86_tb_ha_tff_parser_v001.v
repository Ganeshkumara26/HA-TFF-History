`timescale 1ns / 1ps

module tb_ha_tff_parser_v001;

    reg clk;
    reg rst;
    
    reg [7:0] s_axis_tdata;
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

    ha_tff_parser_v001 uut (
        .clk(clk),
        .rst(rst),
        .s_axis_tdata(s_axis_tdata),
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
        $dumpfile("tb_ha_tff_parser_v001.vcd");
        $dumpvars(0, tb_ha_tff_parser_v001);
        clk = 0;
        forever #5 clk = ~clk; // 100 MHz
    end

    // Concurrent checker
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

    // Helper task to send a byte
    task send_byte(input [7:0] data, input is_last);
        begin
            @(posedge clk);
            s_axis_tvalid <= 1;
            s_axis_tdata <= data;
            s_axis_tlast <= is_last;
        end
    endtask

    integer i;

    initial begin
        rst = 1;
        s_axis_tvalid = 0;
        s_axis_tdata = 0;
        s_axis_tlast = 0;
        
        #100;
        rst = 0;
        #20;
        
        $display("[%0t] Sending Valid UDP Packet...", $time);
        
        // Byte 0-5: Dst MAC
        for (i=0; i<6; i=i+1) send_byte(8'hFF, 0);
        // Byte 6-11: Src MAC
        for (i=0; i<6; i=i+1) send_byte(8'hEE, 0);
        // Byte 12-13: EtherType (IPv4 = 0800)
        send_byte(8'h08, 0); send_byte(8'h00, 0);
        
        // Byte 14: Version/IHL (0x45)
        send_byte(8'h45, 0);
        // Byte 15: TOS
        send_byte(8'h00, 0);
        // Byte 16-17: Total Length
        send_byte(8'h00, 0); send_byte(8'h28, 0);
        // Byte 18-19: Identification
        send_byte(8'hAB, 0); send_byte(8'hCD, 0);
        // Byte 20-21: Flags/Offset
        send_byte(8'h40, 0); send_byte(8'h00, 0);
        // Byte 22: TTL
        send_byte(8'h40, 0);
        // Byte 23: Protocol (UDP = 0x11)
        send_byte(8'h11, 0);
        // Byte 24-25: Header Checksum
        send_byte(8'h00, 0); send_byte(8'h00, 0);
        
        // Byte 26-29: Src IP (192.168.1.100 -> C0 A8 01 64)
        send_byte(8'hC0, 0); send_byte(8'hA8, 0); send_byte(8'h01, 0); send_byte(8'h64, 0);
        // Byte 30-33: Dst IP (10.0.0.5 -> 0A 00 00 05)
        send_byte(8'h0A, 0); send_byte(8'h00, 0); send_byte(8'h00, 0); send_byte(8'h05, 0);
        
        // Byte 34-35: Src Port (1234 -> 04 D2)
        send_byte(8'h04, 0); send_byte(8'hD2, 0);
        // Byte 36-37: Dst Port (80 -> 00 50)
        send_byte(8'h00, 0); send_byte(8'h50, 0);
        
        // Byte 38-41: UDP Length & Checksum
        send_byte(8'h00, 0); send_byte(8'h08, 0);
        send_byte(8'h00, 0); send_byte(8'h00, 0);
        
        // Payload
        send_byte(8'hDE, 0);
        send_byte(8'hAD, 0);
        send_byte(8'hBE, 0);
        send_byte(8'hEF, 1); // tlast = 1
        
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

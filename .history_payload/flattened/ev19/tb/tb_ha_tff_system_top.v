`timescale 1ns / 1ps

module tb_ha_tff_system_top;

    reg clk;
    reg rst;

    reg [63:0]  s_axis_tdata;
    reg [7:0]   s_axis_tkeep;
    reg         s_axis_tvalid;
    reg         s_axis_tlast;
    wire        s_axis_tready;

    wire [63:0] m_axis_tdata;
    wire [7:0]  m_axis_tkeep;
    wire        m_axis_tvalid;
    wire        m_axis_tlast;
    reg         m_axis_tready;

    ha_tff_system_top_v001 uut (
        .clk(clk),
        .rst(rst),
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tkeep(s_axis_tkeep),
        .s_axis_tvalid(s_axis_tvalid),
        .s_axis_tlast(s_axis_tlast),
        .s_axis_tready(s_axis_tready),
        .m_axis_tdata(m_axis_tdata),
        .m_axis_tkeep(m_axis_tkeep),
        .m_axis_tvalid(m_axis_tvalid),
        .m_axis_tlast(m_axis_tlast),
        .m_axis_tready(m_axis_tready)
    );

    initial begin
        $dumpfile("tb_ha_tff_system_top.vcd");
        $dumpvars(0, tb_ha_tff_system_top);
        clk = 0;
        forever #3.2 clk = ~clk;
    end
    
    // Monitor Drop/Forward Activity
    always @(posedge clk) begin
        if (m_axis_tvalid && m_axis_tready) begin
            $display("[%0t] SYSTEM OUT: Packet Forwarded", $time);
        end
        if (uut.anomaly_detected) begin
            $display("[%0t] SNN TRIGGERED: Anomaly Active! All traffic dropping.", $time);
        end
    end

    // The Parser takes 1 cycle. The Cuckoo Hash takes 2 cycles.
    // The SNN evaluates the parser output. Let's build a task to inject packets.
    task inject_packet(input [31:0] sip, input [31:0] dip, input [15:0] sport, input [15:0] dport, input [7:0] proto);
        begin
            @(posedge clk);
            s_axis_tvalid <= 1;
            // Byte 0-5: MAC DA, 6-11: MAC SA, 12-13: EtherType (0800), 14-33: IPv4, 34-41: UDP
            // To simplify, we just place the tuple correctly based on the parser logic.
            // Parser extracts: src_ip=data[239:208], dst_ip=data[271:240], src_port=data[287:272], dst_port=data[303:288]
            // We'll inject just a dummy 64-bit word that the parser captures in cycle 4.
            // Actually, we'll just force the tuple out of the parser for the sake of SNN testing without complex packet formatting.
            
            // Wait! The `tb_ha_tff_system_top` injects raw 64-bit AXI stream. 
            // Writing a full 64-byte packet just to test SNN override is tedious.
            // Instead, we will simulate the parser metadata directly in this TB.
        end
    endtask

    initial begin
        rst = 1;
        s_axis_tvalid = 0;
        m_axis_tready = 1;
        
        #100;
        rst = 0;
        
        // Due to the complexity of formatting exact Ethernet frames in AXI-64,
        // we will directly force the tuple wires inside the UUT for anomaly generation testing.
        
        #50;
        $display("[%0t] Forcing Safe Traffic Metadata", $time);
        force uut.parser_snn_inst.tuple_valid = 1;
        // proto=6 (TCP), src_port=10000, dst_port=80, src_ip=10.0.0.1, dst_ip=8.8.8.8
        force uut.parser_snn_inst.src_ip = 32'h0A000001;
        force uut.parser_snn_inst.dst_ip = 32'h08080808;
        force uut.parser_snn_inst.src_port = 16'd10000;
        force uut.parser_snn_inst.dst_port = 16'd80;
        force uut.parser_snn_inst.protocol = 8'd6;
        
        #250;
        $display("[%0t] Forcing Anomaly Traffic Metadata (UDP, High Port, Multicast, DNS)", $time);
        // proto=17 (UDP), src_port=50000, dst_port=53, dst_ip=255
        force uut.parser_snn_inst.src_ip = 32'h0A000001;
        force uut.parser_snn_inst.dst_ip = 32'h080808FF;
        force uut.parser_snn_inst.src_port = 16'd50000;
        force uut.parser_snn_inst.dst_port = 16'd53;
        force uut.parser_snn_inst.protocol = 8'd17;
        
        #200;
        // While anomaly is active, inject a valid packet on AXI interface to see if it gets dropped.
        force uut.dp_match_valid = 1;
        force uut.dp_action_forward = 1;
        
        #10;
        if (uut.final_forward == 0) begin
            $display("[%0t] SUCCESS: System correctly blocked packet due to Anomaly Override!", $time);
        end else begin
            $display("[%0t] FAILURE: Packet leaked through!", $time);
        end
        
        force uut.dp_match_valid = 0;
        
        #100;
        $finish;
    end

endmodule

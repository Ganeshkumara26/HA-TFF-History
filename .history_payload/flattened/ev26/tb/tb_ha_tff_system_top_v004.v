`timescale 1ns / 1ps

module tb_ha_tff_system_top_v004;

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

    ha_tff_system_top_v004 uut (
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
        $dumpfile("tb_ha_tff_system_top_v004.vcd");
        $dumpvars(0, tb_ha_tff_system_top_v004);
        clk = 0;
        forever #3.2 clk = ~clk; // 156.25 MHz (6.4ns period)
    end
    
    always @(posedge clk) begin
        if (m_axis_tvalid && m_axis_tready) begin
            $display("[%0t] SYSTEM OUT: Packet Forwarded. Data: %h", $time, m_axis_tdata);
        end
        if (uut.anomaly_detected) begin
            $display("[%0t] SNN TRIGGERED: Anomaly Active! All traffic dropping.", $time);
        end
    end

    initial begin
        rst = 1;
        s_axis_tvalid = 0;
        s_axis_tdata = 0;
        m_axis_tready = 1;
        
        #100;
        rst = 0;
        
        #50;
        $display("[%0t] INJECTING: Safe Traffic Metadata", $time);
        force uut.parser_snn_inst.tuple_valid = 1;
        force uut.parser_snn_inst.src_ip = 32'h0A000001;
        force uut.parser_snn_inst.dst_ip = 32'h08080808;
        force uut.parser_snn_inst.src_port = 16'd10000;
        force uut.parser_snn_inst.dst_port = 16'd80;
        force uut.parser_snn_inst.protocol = 8'd6;
        
        force uut.datapath_inst.match_valid = 1;
        force uut.datapath_inst.action_forward = 1;
        
        s_axis_tvalid = 1;
        s_axis_tdata  = 64'h5AFE_CAFE_BEEF_0001;
        
        #6.4; // 1 cycle
        s_axis_tvalid = 0;
        s_axis_tdata  = 0;
        
        #250;
        $display("[%0t] INJECTING: Anomaly Traffic Metadata (UDP, High Port, Multicast, DNS)", $time);
        force uut.parser_snn_inst.src_ip = 32'h0A000001;
        force uut.parser_snn_inst.dst_ip = 32'h080808FF;
        force uut.parser_snn_inst.src_port = 16'd50000;
        force uut.parser_snn_inst.dst_port = 16'd53;
        force uut.parser_snn_inst.protocol = 8'd17;
        
        #200;
        // While anomaly is active, inject a valid packet on AXI interface
        s_axis_tvalid = 1;
        s_axis_tdata  = 64'hBAD0_BAD0_BAD0_BAD0;
        
        #6.4; // 1 cycle
        s_axis_tvalid = 0;
        s_axis_tdata  = 0;
        
        #100;
        $finish;
    end

endmodule

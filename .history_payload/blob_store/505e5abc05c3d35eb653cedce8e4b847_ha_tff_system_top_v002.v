`timescale 1ns / 1ps

// Hardware-Accelerated Traffic Filter Firewall (HA-TFF) - SYSTEM TOP v002
// Fixes BUG-005: correctly routes Datapath Output through the SNN Override Logic to the OBUFs.

module ha_tff_system_top_v002 (
    input  wire         clk,
    input  wire         rst,

    // AXI4-Stream Input (10GbE MAC)
    input  wire [63:0]  s_axis_tdata,
    input  wire [7:0]   s_axis_tkeep,
    input  wire         s_axis_tvalid,
    input  wire         s_axis_tlast,
    output wire         s_axis_tready,

    // AXI4-Stream Output (To Network)
    output wire [63:0]  m_axis_tdata,
    output wire [7:0]   m_axis_tkeep,
    output wire         m_axis_tvalid,
    output wire         m_axis_tlast,
    input  wire         m_axis_tready
);

    wire [31:0] src_ip;
    wire [31:0] dst_ip;
    wire [15:0] src_port;
    wire [15:0] dst_port;
    wire [7:0]  protocol;
    wire        tuple_valid;
    wire        parse_error;
    
    ha_tff_parser_v002 parser_snn_inst (
        .clk(clk),
        .rst(rst),
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tkeep(s_axis_tkeep),
        .s_axis_tvalid(s_axis_tvalid),
        .s_axis_tlast(s_axis_tlast),
        .s_axis_tready(), // Ignored, handled by datapath
        .src_ip(src_ip),
        .dst_ip(dst_ip),
        .src_port(src_port),
        .dst_port(dst_port),
        .protocol(protocol),
        .tuple_valid(tuple_valid),
        .parse_error(parse_error)
    );

    wire [7:0]  snn_spikes_in;
    wire        snn_spikes_valid;
    
    snn_feature_encoder encoder_inst (
        .clk(clk),
        .rst(rst),
        .src_ip(src_ip),
        .dst_ip(dst_ip),
        .src_port(src_port),
        .dst_port(dst_port),
        .protocol(protocol),
        .meta_valid(tuple_valid),
        .out_spikes(snn_spikes_in),
        .spike_valid(snn_spikes_valid)
    );
    
    wire [1:0] snn_out_spikes;
    wire       snn_out_valid;
    
    snn_tff_layer_v003 snn_core (
        .clk(clk),
        .rst(rst),
        .in_spikes(snn_spikes_in),
        .valid_in(snn_spikes_valid),
        .out_spikes(snn_out_spikes),
        .valid_out(snn_out_valid)
    );
    
    reg anomaly_detected;
    always @(posedge clk) begin
        if (rst) begin
            anomaly_detected <= 0;
        end else if (snn_out_spikes[1]) begin
            anomaly_detected <= 1'b1; 
        end else if (snn_out_spikes[0]) begin
            anomaly_detected <= 1'b0;
        end
    end

    wire dp_match_valid;
    wire dp_match_found;
    wire dp_action_forward;
    
    ha_tff_datapath_top_v002 datapath_inst (
        .clk(clk),
        .rst(rst),
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tkeep(s_axis_tkeep),
        .s_axis_tvalid(s_axis_tvalid),
        .s_axis_tlast(s_axis_tlast),
        .s_axis_tready(s_axis_tready),
        .match_valid(dp_match_valid),
        .match_found(dp_match_found),
        .action_forward(dp_action_forward),
        .parse_error()
    );

    wire final_forward = (dp_match_valid && dp_action_forward && !anomaly_detected);
    
    // Output datapath. We pass the input raw data to the output, but only if the firewall allows it.
    assign m_axis_tdata  = s_axis_tdata;
    assign m_axis_tkeep  = s_axis_tkeep;
    assign m_axis_tlast  = s_axis_tlast;
    assign m_axis_tvalid = (s_axis_tvalid && final_forward);

endmodule

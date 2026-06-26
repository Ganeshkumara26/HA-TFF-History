`timescale 1ns / 1ps

module ha_tff_parser_v001 (
    input  wire        clk,
    input  wire        rst,
    
    // AXI4-Stream Sink Interface
    input  wire [7:0]  s_axis_tdata,
    input  wire        s_axis_tvalid,
    input  wire        s_axis_tlast,
    output wire        s_axis_tready,
    
    // Extracted 5-tuple output
    output reg  [31:0] src_ip,
    output reg  [31:0] dst_ip,
    output reg  [15:0] src_port,
    output reg  [15:0] dst_port,
    output reg  [7:0]  protocol,
    output reg         tuple_valid,
    output reg         parse_error
);

    // We can always consume data in this simple model
    assign s_axis_tready = 1'b1;

    localparam STATE_IDLE  = 2'd0;
    localparam STATE_PARSE = 2'd1;
    localparam STATE_DROP  = 2'd2;

    reg [1:0]  state;
    reg [15:0] byte_cnt;
    
    reg [15:0] ethertype;

    always @(posedge clk) begin
        if (rst) begin
            state       <= STATE_IDLE;
            byte_cnt    <= 0;
            tuple_valid <= 0;
            parse_error <= 0;
            src_ip      <= 0;
            dst_ip      <= 0;
            src_port    <= 0;
            dst_port    <= 0;
            protocol    <= 0;
            ethertype   <= 0;
        end else begin
            tuple_valid <= 0; // Default to 0
            
            case (state)
                STATE_IDLE: begin
                    byte_cnt <= 0;
                    parse_error <= 0;
                    if (s_axis_tvalid) begin
                        state <= STATE_PARSE;
                        byte_cnt <= 1;
                    end
                end
                
                STATE_PARSE: begin
                    if (s_axis_tvalid) begin
                        byte_cnt <= byte_cnt + 1;
                        
                        case (byte_cnt)
                            12: ethertype[15:8] <= s_axis_tdata;
                            13: ethertype[7:0]  <= s_axis_tdata;
                            23: protocol        <= s_axis_tdata;
                            
                            26: src_ip[31:24] <= s_axis_tdata;
                            27: src_ip[23:16] <= s_axis_tdata;
                            28: src_ip[15:8]  <= s_axis_tdata;
                            29: src_ip[7:0]   <= s_axis_tdata;
                            
                            30: dst_ip[31:24] <= s_axis_tdata;
                            31: dst_ip[23:16] <= s_axis_tdata;
                            32: dst_ip[15:8]  <= s_axis_tdata;
                            33: dst_ip[7:0]   <= s_axis_tdata;
                            
                            34: src_port[15:8] <= s_axis_tdata;
                            35: src_port[7:0]  <= s_axis_tdata;
                            
                            36: dst_port[15:8] <= s_axis_tdata;
                            37: begin
                                dst_port[7:0] <= s_axis_tdata;
                                // Verify constraints before asserting valid
                                if (ethertype == 16'h0800 && (protocol == 8'h11 || protocol == 8'h06)) begin
                                    tuple_valid <= 1;
                                end else begin
                                    parse_error <= 1;
                                end
                            end
                        endcase
                        
                        if (s_axis_tlast) begin
                            state <= STATE_IDLE;
                        end
                    end
                end
                
                STATE_DROP: begin
                    if (s_axis_tvalid && s_axis_tlast) begin
                        state <= STATE_IDLE;
                    end
                end
                
                default: state <= STATE_IDLE;
            endcase
        end
    end

endmodule

# Vivado Synthesis Script for HA-TFF Full System v003 (Iteration 011)
create_project -in_memory -part xc7a100tcsg324-1

read_verilog ../../05_RTL/rtl_v001/ha_tff_parser_v001.v
read_verilog ../../05_RTL/rtl_v002/ha_tff_parser_v002.v
read_verilog ../../05_RTL/rtl_v003/ha_tff_hash_v001.v
read_verilog ../../05_RTL/rtl_v004/ha_tff_bram_bank.v
read_verilog ../../05_RTL/rtl_v005/ha_tff_matcher_v002.v
read_verilog ../../05_RTL/rtl_v005/ha_tff_datapath_top_v002.v
read_verilog ../../05_RTL/rtl_v008/snn_tff_neuron_v003.v
read_verilog ../../05_RTL/rtl_v008/snn_tff_layer_v003.v
read_verilog ../../05_RTL/rtl_v009/snn_feature_encoder.v
read_verilog ../../05_RTL/rtl_v011/axi_stream_delay_line.v
read_verilog ../../05_RTL/rtl_v011/ha_tff_system_top_v003.v

synth_design -top ha_tff_system_top_v003 -part xc7a100tcsg324-1

# Constraints for 156.25 MHz clock (6.4ns)
create_clock -period 6.400 -name clk [get_ports clk]

report_utilization -file utilization_report.txt
report_timing_summary -file ../../09_Timing/timing011/timing_summary.txt

write_checkpoint -force ha_tff_system_top_v003_synth.dcp

# Vivado Synthesis Script for HA-TFF Datapath Top (v004)
create_project -in_memory -part xc7a100tcsg324-1

read_verilog ../../05_RTL/rtl_v002/ha_tff_parser_v002.v
read_verilog ../../05_RTL/rtl_v003/ha_tff_hash_v001.v
read_verilog ../../05_RTL/rtl_v004/ha_tff_bram_bank.v
read_verilog ../../05_RTL/rtl_v004/ha_tff_matcher.v
read_verilog ../../05_RTL/rtl_v004/ha_tff_datapath_top.v

synth_design -top ha_tff_datapath_top -part xc7a100tcsg324-1

# Constraints for 156.25 MHz clock (6.4ns)
create_clock -period 6.400 -name clk [get_ports clk]

report_utilization -file utilization_report.txt
report_timing_summary -file ../../09_Timing/timing004/timing_summary.txt
report_power -file power_report.txt

write_checkpoint -force ha_tff_datapath_top_synth.dcp

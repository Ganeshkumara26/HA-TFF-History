# Vivado Synthesis Script for HA-TFF Parser v002
create_project -in_memory -part xcvu9p-flga2104-2L-e

read_verilog ../../05_RTL/rtl_v002/ha_tff_parser_v002.v

# Constraints for 156.25 MHz clock (6.4ns)
create_clock -period 6.400 -name clk [get_ports clk]

synth_design -top ha_tff_parser_v002 -part xcvu9p-flga2104-2L-e

report_utilization -file utilization_report.txt
report_timing_summary -file ../../09_Timing/timing001/timing_summary.txt
report_power -file power_report.txt

write_checkpoint -force ha_tff_parser_v002_synth.dcp

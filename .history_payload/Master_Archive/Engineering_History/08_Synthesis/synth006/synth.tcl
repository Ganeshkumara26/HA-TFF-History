# Vivado Synthesis Script for SNN-TFF Prototype (v006)
create_project -in_memory -part xc7a100tcsg324-1

read_verilog ../../05_RTL/rtl_v006/snn_tff_neuron.v
read_verilog ../../05_RTL/rtl_v006/snn_tff_layer.v

synth_design -top snn_tff_layer -part xc7a100tcsg324-1

# Constraints for 156.25 MHz clock (6.4ns)
create_clock -period 6.400 -name clk [get_ports clk]

report_utilization -file utilization_report.txt
report_timing_summary -file ../../09_Timing/timing006/timing_summary.txt

write_checkpoint -force snn_tff_layer_synth.dcp

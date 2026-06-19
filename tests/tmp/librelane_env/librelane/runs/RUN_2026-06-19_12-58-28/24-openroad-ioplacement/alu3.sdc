###############################################################################
# Created by write_sdc
###############################################################################
current_design alu3
###############################################################################
# Timing Constraints
###############################################################################
create_clock -name __VIRTUAL_CLK__ -period 100.0000 
set_clock_uncertainty 0.2500 __VIRTUAL_CLK__
set_input_delay 20.0000 -clock [get_clocks {__VIRTUAL_CLK__}] -add_delay [get_ports {i0}]
set_input_delay 20.0000 -clock [get_clocks {__VIRTUAL_CLK__}] -add_delay [get_ports {i1}]
set_input_delay 20.0000 -clock [get_clocks {__VIRTUAL_CLK__}] -add_delay [get_ports {i2}]
set_input_delay 20.0000 -clock [get_clocks {__VIRTUAL_CLK__}] -add_delay [get_ports {i3}]
set_input_delay 20.0000 -clock [get_clocks {__VIRTUAL_CLK__}] -add_delay [get_ports {i4}]
set_input_delay 20.0000 -clock [get_clocks {__VIRTUAL_CLK__}] -add_delay [get_ports {i5}]
set_input_delay 20.0000 -clock [get_clocks {__VIRTUAL_CLK__}] -add_delay [get_ports {i6}]
set_input_delay 20.0000 -clock [get_clocks {__VIRTUAL_CLK__}] -add_delay [get_ports {i7}]
set_input_delay 20.0000 -clock [get_clocks {__VIRTUAL_CLK__}] -add_delay [get_ports {i8}]
set_input_delay 20.0000 -clock [get_clocks {__VIRTUAL_CLK__}] -add_delay [get_ports {i9}]
set_output_delay 20.0000 -clock [get_clocks {__VIRTUAL_CLK__}] -add_delay [get_ports {o0}]
set_output_delay 20.0000 -clock [get_clocks {__VIRTUAL_CLK__}] -add_delay [get_ports {o1}]
set_output_delay 20.0000 -clock [get_clocks {__VIRTUAL_CLK__}] -add_delay [get_ports {o2}]
set_output_delay 20.0000 -clock [get_clocks {__VIRTUAL_CLK__}] -add_delay [get_ports {o3}]
set_output_delay 20.0000 -clock [get_clocks {__VIRTUAL_CLK__}] -add_delay [get_ports {o4}]
set_output_delay 20.0000 -clock [get_clocks {__VIRTUAL_CLK__}] -add_delay [get_ports {o5}]
set_output_delay 20.0000 -clock [get_clocks {__VIRTUAL_CLK__}] -add_delay [get_ports {o6}]
set_output_delay 20.0000 -clock [get_clocks {__VIRTUAL_CLK__}] -add_delay [get_ports {o7}]
###############################################################################
# Environment
###############################################################################
set_load -pin_load 0.0334 [get_ports {o0}]
set_load -pin_load 0.0334 [get_ports {o1}]
set_load -pin_load 0.0334 [get_ports {o2}]
set_load -pin_load 0.0334 [get_ports {o3}]
set_load -pin_load 0.0334 [get_ports {o4}]
set_load -pin_load 0.0334 [get_ports {o5}]
set_load -pin_load 0.0334 [get_ports {o6}]
set_load -pin_load 0.0334 [get_ports {o7}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {i0}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {i1}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {i2}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {i3}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {i4}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {i5}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {i6}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {i7}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {i8}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {i9}]
###############################################################################
# Design Rules
###############################################################################
set_max_transition 0.7500 [current_design]
set_max_capacitance 0.2000 [current_design]
set_max_fanout 10.0000 [current_design]

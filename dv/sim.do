# set the working dir, where all compiled verilog goes
# DO NOT CHANGE
vlib work


# compile rtl
# === CHANGE HERE ===
# vlog ../*.sv

vlog ../fip_opts.sv
vlog ../intersection.sv


# compile testbench
# === CHANGE HERE ===
# vlog *.sv

vlog fip_opts_tb.sv
# vlog intersection_tb.sv


# load top level simulation module
# === CHANGE HERE ===

# vsim fip_32_mult_tb
# vsim fip_32_div_tb
vsim fip_32_3b3_det_tb
# vsim fip_32_vector_cross_tb
# vsim fip_32_vector_normal_tb

# vsim intersection_tb


# log all signals
log {/*}

# add all items in top level simulation module
add wave {/*}

# simulate
run -all

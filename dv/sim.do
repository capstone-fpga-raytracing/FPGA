# set the working dir, where all compiled verilog goes
# DO NOT CHANGE
vlib work


# compile required verilog modules to working dir
# source files
# vlog ../*.sv
vlog ../fip_opts.sv
vlog ../intersection.sv


# testbenches
# vlog *.sv
vlog fip_32b_tb.sv
vlog intersection_tb.sv


# load simulation using the top level simulation module
# === CHANGE HERE ===

# vsim tb_fip_32_adder
# vsim tb_fip_32_sub
# vsim tb_fip_32_mult
# vsim tb_fip_32_div
# vsim tb_fip_32_3b3_det
# vsim fip_32_vector_cross_tb
# vsim fip_32_vector_normal_tb

vsim intersection_tb



# log all signals
log {/*}

# add all items in top level simulation module
add wave {/*}

# simulate
run -all

# set the working dir, where all compiled verilog goes
# DO NOT CHANGE "work"
vlib work


# compile required verilog modules to working dir
# source files
vlog ../fip_opts.sv
vlog ../3det.sv
vlog ../intersection.sv

# testbenches
vlog fip_32b_tb.sv
vlog intersection_tb.sv


#load simulation using the top level simulation module
# vsim tb_fip_32_adder
vsim intersection_tb


#log all signals
log {/*}

# add all items in top level simulation module
add wave {/*}

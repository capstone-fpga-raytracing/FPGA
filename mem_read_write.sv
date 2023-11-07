module mem_read_write(
	input clk,
	input reset,
	input [15:0] sdram_readdata,
	input sdram_waitrequest,
	input sdram_readdatavalid,
	output reg [24:0] sdram_address,
	output reg [1:0] sdram_byteenable,
	output reg [15:0] sdram_writedata,
	output reg sdram_read,
	output reg sdram_chipselect,
	output reg sdram_write,

	output [15:0] dat
);
    localparam S_WAIT = 2'd0,
	           S_WRITE = 2'd1,
			   S_READ = 2'd2,
			   S_OUT = 2'd3;

	reg [1:0] next, cur;

	assign dat = sdram_readdata;

	always_comb
	begin
		case(cur)
			S_WAIT: next = reset ? S_WAIT : S_WRITE;
			S_WRITE: next = S_READ;
			S_READ: next = S_OUT;
			S_OUT: next = S_OUT;
			default: next = S_WAIT;
		endcase
	end

	always_comb
	begin
		sdram_read = 1'b0;
		sdram_chipselect = 1'b0;
		sdram_write = 1'b0;
		sdram_address = 25'd0;
		sdram_byteenable = 2'd0;
		sdram_writedata = 16'd0;

		case(cur)
			S_WRITE:
			begin
				sdram_write = 1'b1;
				sdram_address = 25'd0;
				sdram_byteenable = 2'b11;
				sdram_writedata = 16'd36;
				sdram_chipselect = 1'b1;
			end
			S_READ: 
			begin
				sdram_read = 1'b1;
				sdram_address = 25'd0;
				sdram_byteenable = 2'b11;
				sdram_chipselect = 1'b1;
			end
		endcase
	end

	always_ff@(posedge clk) begin
		if (reset)
			cur <= S_WAIT;
		else
			cur <= next;
	end
	
endmodule
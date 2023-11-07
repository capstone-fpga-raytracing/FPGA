module rdh(
	input clk,
	input enable,
	input reset,
	input [31:0] q_a,
	input [31:0] q_b,

	output [16:0] address_a,
	output [16:0] address_b,
	output rden_a,
	output rden_b,

	output reg [31:0] header[10:0],
	output done
);

	localparam INIT = 0;
	localparam READ_OFFSET = 1;
	localparam RETURN_VAL_AT_OFFSET = 2;
	localparam FINISH = 3;

	logic [1:0] cur_state;
    logic [1:0] next_state;
	
	logic [3:0] count;

	logic read_offset_sig;
	logic offset_valid;
	logic count_enable;
	logic ret_at_offset;


	// State transition on posedge of clk
    always_ff @(posedge clk) begin
        if (reset) cur_state <= INIT;
        else cur_state <= next_state;
    end

	always_ff @(posedge clk) begin
		if(count_enable) begin
			count <= count + 1'b1;
		end
		if(ret_at_offset) begin
			header[count] <= q_a;
		end
	end

	always_comb begin
		next_state = cur_state;	
		read_offset_sig = 1'b0;
		offset_valid = 1'b0;
		count_enable = 1'b0;
		ret_at_offset = 1'b0;

		case(cur_state)

			INIT: begin
				if(enable) next_state = READ_OFFSET;
			end
			READ_OFFSET: begin
				next_state = RETURN_VAL_AT_OFFSET;
				rden_a = 1'b1;
				address_a = count;
			end
			RETURN_VAL_AT_OFFSET: begin
				count_enable = 1'b1;
				ret_at_offset = 1'b1;
				if(count == 11) next_state = FINISH;
				else next_state = READ_OFFSET;
			end
			FINISH: begin
				done = 1'b1;
			end

			default: next_state = INIT;

		endcase
	end
endmodule

// data scenerom(
// 		.clock(clk),
// 		.address_a(17'd0),
// 		.address_b(17'd0),
// 		.rden_a(1'b1),
// 		.rden_b(1'b1),
// 		.q_a(q_a),
// 		.q_b(q_b)
// 	);

// 	 /* size  */ h[0] = nserial();
//     /* numV  */ h[1] = uint(V.size());
//     /* numF  */ h[2] = uint(F.size());
//     /* numL  */ h[3] = uint(L.size());
//     /* Loff  */ h[4] = nserialhdr + camera::nserial;
//     /* Voff  */ h[5] = h[4] + nsL();
//     /* NVoff */ h[6] = h[5] + nsV();
//     /* Foff  */ h[7] = h[6] + nsNV();
//     /* NFoff */ h[8] = h[7] + nsF();
//     /* Moff  */ h[9] = h[8] + nsNF();
//     /* MFoff */ h[10] = h[9] + nsM();
    
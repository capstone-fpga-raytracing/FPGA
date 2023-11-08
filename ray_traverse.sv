	

module ray_traverse(
	input wire clk,
	input wire reset,
	input wire enable,
	input signed wire [31:0] ray_origin[2:0],
	input signed wire [31:0] ray_dir[2:0],
  
  
  input wire [31:0] tree_data,
  output wire [31:0] traversal_result
);

localparam FIXED_MIN = 32'h80000000; // -32768.0 in Q15.16
localparam FIXED_MAX = 32'h7fffffff; // 32767.99998 in Q15.16
localparam UINT_MAX =  32'hffffffff; // -1 as int

reg [31:0] addr_a, addr_b;
reg rden_a, rden_b;

initial begin
	addr_a = 32'd0;
	addr_b = 32'd0;
	rden_a = 1'b1;
	rden_b = 1'b1;
end

wire [31:0] q_a, q_b;

data scenerom(
	.clock(clk),
	.address_a(addr_a[17:0]),
	.address_b(addr_b[17:0]),
	.rden_a(rden_a),
	.rden_b(rden_b),
	.q_a(q_a),
	.q_b(q_b)
);


// ray_intersect_box.cpp
// haha insect
module ray_insect_bbox(
	input wire start,
	output reg done,
	output reg did_insect
);

localparam READ_BBOX_DIM = 3'd0;
localparam CALC_INSECT = 3'd1;
localparam CHECK_INSECT = 3'd2;

reg [1:0] state;
reg [1:0] cnt;
initial begin
	state = READ_BBOX_DIM;
	cnt = 2'd0;
end

reg [31:0] t_entr;
reg [31:0] t_exit;
initial begin
	t_entr = FIXED_MIN;
	t_exit = FIXED_MAX;
end

wire [47:0] new_tentr_tmp, new_texit_tmp;
wire [31:0] new_tentr, new_texit;

// calculate intersection
assign new_tentr_tmp = ({16'd0, q_a - ray_origin[cnt]} << 16) / ray_dir[cnt];
assign new_texit_tmp = ({16'd0, q_b - ray_origin[cnt]} << 16) / ray_dir[cnt];
assign new_tentr = new_tentr_tmp[31:0];
assign new_texit = new_texit_tmp[31:0];


always_ff @(posedge clk)
begin
case (state)
	READ_BBOX_DIM: begin
		if (start) begin
			addr_a <= node_ptr + cnt;
			addr_b <= node_ptr + cnt + 32'd3;
			state <= CALC_INSECT;
		end
	end
	
	// ray intersects when max(tentrys) <= min(texits)
	CALC_INSECT: begin
		if (ray_dir[cnt] != 32'd0)
		begin			
			if (ray_dir[cnt][31] == 1'b0) // ray_dir[i] > 0?
			begin
				t_entr <= (new_tentr > t_entr) ? new_tentr : t_entr;
				t_exit <= (new_texit < t_exit) ? new_texit : t_exit;
			end else begin
				// swap tentry / texit in direction of ray
				t_entr <= (new_texit > t_entr) ? new_texit : t_entr;
				t_exit <= (new_tentr < t_exit) ? new_tentr : t_exit;
			end
		end
			
		if (cnt == 2'd2)
			state <= CHECK_INSECT;
		else begin
			cnt <= cnt + 2'd1;
			state <= READ_BBOX_DIM;
		end
	end
		
	CHECK_INSECT: begin
		did_insect <= (t_exit >= t_entr && t_exit > 32'd0);
		done <= 1'b1;
		
		// reset for next use
		t_entr <= FIXED_MIN;
		t_exit <= FIXED_MAX;
		cnt <= 2'd0;
		state <= READ_BBOX_DIM;
	end
endcase
end

endmodule


// FSM states
localparam S_IDLE = 8'd0;
localparam S_INIT_0 = 8'd1;
localparam S_INIT_1 = 8'd2;
localparam S_INSECT_NODE0 = 8'd3;
localparam S_INSECT_NODE1 = 8'd4;


reg [7:0] state;
reg [31:0] tree_base, Vbase, NVbase, Fbase;
reg [31:0] node_ptr;
reg [31:0] node_tri;

reg [31:0] stack[31:0];
reg [4:0] stack_ptr;

initial begin
	state = S_IDLE;
	tree_base = 32'd0;
	Vbase = 32'd0;
	Fbase = 32'd0;
	node_ptr = 32'd0;
	node_tri = UINT_MAX;
	stack_ptr = 5'd0;
end

reg insect_start;
wire insect_done;
wire did_insect;

initial begin
	insect_start = 1'b0;
end

ray_insect_bbox insector(
	.start(insect_start),
	.done(insect_done),
	.did_insect(did_insect)
);

always_ff @(posedge clk or posedge reset)
begin
	if (reset) 
	begin
		state <= S_IDLE;
		tree_base <= 32'd0;
		Vbase <= 32'd0;
		Fbase <= 32'd0;
		node_ptr <= 32'd0;
		stack_ptr <= 5'd0;
		insect_start <= 1'b0;
		
	end else if (enable) begin
		case(state)
			S_IDLE: begin
				addr_a <= 32'd0;
				addr_b <= 32'd5;			
				state <= S_INIT_0;
			end
			
			S_INIT_0: begin
				tree_base <= q_a;
				Vbase <= q_b;
				
				addr_a <= 32'd6;
				addr_b <= 32'd7;			
				state <= S_INIT_1;
			end
			
			S_INIT_1: begin
				NVbase <= q_a;
				Fbase <= q_b;
				node_ptr <= tree_base;
				
				state <= S_INSECT_NODE0;
			end
			
			S_INSECT_NODE0: begin
				insect_start <= 1'b1;
				state <= S_INSECT_NODE1;
			end
			
			S_INSECT_NODE1: begin
				addr_a <= node_ptr + 32'd6; // tri
				addr_b <= node_ptr + 32'd7; // left
				state <= S_INSECT_NODE2;
			end
			
			S_INSECT_NODE2:
				if (q_a == UINT_MAX && )
				
				if (insect_done) begin
					if (did_insect) begin
						if (
							stack[stack_ptr] <= node_ptr;
							stack_ptr <= stack_ptr + 5'd1;
						
					end
					
				end
			end
			
			
		endcase
		
		
		next_state <= S_INIT_0;
	else if (
		next_state <= cur_state;
	
	end
end

  



reg init0, init1;

// State table
always_comb 
begin: state_table

init0 = 1'b0;
init1 = 1'b0;

case (cur_state)
	S_IDLE: next_state = enable ? S_INIT_0 : S_IDLE;

	S_INIT_0: begin
		next_state = S_INIT_1;
		
end
 
endcase
end


// --------------------- Datapath --------------------




always_ff @(posedge clk) begin
	if (init0) begin
		rden_a <= 1'b1;
		addr_a <= 32'd0;
		rden_b <= 1'b1;;
		addr_b <= 32'd;
	end

end






// Internal registers
reg [31:0] node_data;
reg [31:0] left_child_data;
reg [31:0] right_child_data;
reg [31:0] traversal_result_reg;



// State machine signals
reg [1:0] state;


// Initial state
initial begin
  state = IDLE;
  stack_pointer = 0;
end

// State machine
always @(posedge clk or posedge reset) begin
  if (reset) begin
    state <= IDLE;
    stack_pointer <= 0;
    traversal_result_reg <= 0;
  end else if (enable) begin
    case (state)
      IDLE: begin
        if (tree_data != 0) begin
          node_data <= tree_data;
          stack[stack_pointer] <= node_data;
          stack_pointer <= stack_pointer + 1;
          state <= TRAVERSE_LEFT;
        end else begin
          state <= FINISH;
        end
      end

      TRAVERSE_LEFT: begin
        if (node_data[31] == 1) begin
          left_child_data <= node_data[30:0];
          node_data <= left_child_data;
          stack[stack_pointer] <= node_data;
          stack_pointer <= stack_pointer + 1;
          state <= TRAVERSE_LEFT;
        end else begin
          state <= TRAVERSE_RIGHT;
        end
      end

      TRAVERSE_RIGHT: begin
        if (node_data[31] == 1) begin
          right_child_data <= node_data[30:0];
          node_data <= right_child_data;
          stack[stack_pointer] <= node_data;
          stack_pointer <= stack_pointer + 1;
          state <= TRAVERSE_LEFT;
        end else begin
          state <= FINISH;
        end
      end

      FINISH: begin
        stack_pointer <= stack_pointer - 1;
        if (stack_pointer >= 0) begin
          node_data <= stack[stack_pointer];
          state <= TRAVERSE_RIGHT;
        end else begin
          traversal_result_reg <= traversal_result_reg + 1;
          if (traversal_result_reg == 32) begin
            traversal_result <= traversal_result_reg;
            state <= IDLE;
          end else begin
            state <= FINISH;
          end
        end
      end
    endcase
  end
end

endmodule
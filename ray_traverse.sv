
module ray_traverse(
	input wire clk,
  input wire reset,
  input wire enable,
  input wire [31:0] tree_data,
  output wire [31:0] traversal_result
);

wire [31:0] q_a, q_b;

data scenerom(
	.clock(clk),
	.address_a(17'd0),
	.address_b(17'd0),
	.rden_a(1'b1),
	.rden_b(1'b1),
	.q_a(q_a),
	.q_b(q_b)
);
  // Internal registers
  reg [31:0] node_data;
  reg [31:0] left_child_data;
  reg [31:0] right_child_data;
  reg [31:0] traversal_result_reg;

  // State machine states
  localparam IDLE = 0;
  localparam INIT = 1;
  localparam TRAVERSE_LEFT = 2;
  localparam TRAVERSE_RIGHT = 3;
  localparam FINISH = 4;

  // State machine signals
  reg [1:0] state;
  reg [31:0] stack[31:0];
  reg [4:0] stack_pointer;

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
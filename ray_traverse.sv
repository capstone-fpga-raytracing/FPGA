
module ray_traverse(
);

wire [31:0] q_a, q_b;

data scenerom(
	.clock(CLOCK_50),
	.address_a(17'd0),
	.address_b(17'd0),
	.rden_a(1'b1),
	.rden_b(1'b1),
	.q_a(q_a),
	.q_b(q_b)
);

endmodule
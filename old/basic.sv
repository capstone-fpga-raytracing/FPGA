module FA
(
	input x, y, cin,
	output s, cout
);
	assign s = x ^ y ^ cin;
	assign cout = x&y | x&cin | y&cin;
endmodule: FA

module adder #(parameter W = 32) // ripple carry
(
    input [W-1:0] x,
    input [W-1:0] y,
    input sub,
    output [W:0] sum
);
    logic [W:0] cin;

    assign cin[0] = sub;
    assign sum[W] = cin[W];

    genvar i;
    generate
        for (i = 0; i < W; i++) begin: FAs
            FA fa_inst (.x(x[i]), .y(y[i] ^ sub), .cin(cin[i]), .s(sum[i]), .cout(cin[i+1]));
        end
    endgenerate
endmodule: adder

module mult #(parameter W = 32) // carry save
(
    input [W-1:0] x,
    input [W-1:0] y,
    output [W*2-1:0] out
);
	logic [W*2-1:0] pp[W+1];
	assign pp[0] = '0;
	assign pp[1][W] = '0; // xin of FA[1][W]
	
	logic [W*2:0] cin[W+1];
	assign cin[0] = '0;

	genvar i, j; // index is for FA, pp and index is on target FA (i row from 1-W, j column from 0-(W-1))
	generate
		for (j = 0; j < W; j++) begin: row0
			assign cin[1][j+1] = x[j]&y[1];
			assign pp[1][j] = x[j]&y[0];
		end

		for (i = 1; i < W-1; i++) begin: row
			for (j = 0; j < i; j++) begin: column_without_fa
				assign pp[i+1][j] = pp[i][j]; // pass through
			end

			FA fa_inst (.x(pp[i][i]), .y(1'b0), .cin(cin[i][i]), .s(pp[i+1][i]), .cout(cin[i+1][i+1])); // FA first

			for (j = i+1; j < i + W; j++) begin: column_fa_rest
				FA fa_inst (.x(pp[i][j]), .y(x[j-i-1]&y[i+1]), .cin(cin[i][j]), .s(pp[i+1][j]), .cout(cin[i+1][j+1])); // FA rest
			end

			assign pp[i+1][i+W] = x[W-1]&y[i+1]; // xin of FA last of next level
		end
	endgenerate

	// Have a adder to add the numbers in columns W-1 through W*2-2 of 
	// the final row of the multiplier to get out[W*2-1:W-1]
	
	RCA rca_inst (.x(pp[W-1][W*2-2:W-1]), .y(cin[W-1][W*2-2:W-1]), .sum(out[W*2-1:W-1]));
	
	// Set the lower W-1 bits of the final multiplier output
	assign out[W-2:0] = pp[W-1][W-2:0];

endmodule

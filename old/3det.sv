module 3b3_det #(parameter W = 32)
(
    input [W-1:0] i_array [2:0][2:0],
    output [W*3+2:0] o_det/*,
    output flag*/
);


    /*
    |a b c|
    |d e f|
    |g h i|
    det = a(ei-fh) + b(fg-di) + c(dh-eg)
    o_det = part1 + part2 + part3
    */
    wire [W*2-1:0] ei, fh, fg, di, dh, eg;
    wire [W*2:0] eifh, fgdi, dheg;
    wire [W*4+1:0] part1, part2, part3; // first (W+1)bits dropped

    mult #(.W(W)) inst_ei (.x(i_array[1][1]), .y(i_array[2][2]), .out(ei));
    mult #(.W(W)) inst_fh (.x(i_array[1][2]), .y(i_array[2][1]), .out(fh));
    adder #(.W(W*2)) inst_eifh (.x(ei), .y(fh), .sub(1'b1), .sum(eifh));
    mult #(.W(W*2+1)) inst_1 (.x({(W+1)'b0, a}), .y(eifh), .out(part1));

    mult #(.W(W)) inst_fg (.x(i_array[1][2]), .y(i_array[2][0]), .out(fg));
    mult #(.W(W)) inst_di (.x(i_array[1][0]), .y(i_array[2][2]), .out(di));
    adder #(.W(W*2)) inst_fgdi (.x(fg), .y(di), .sub(1'b1), .sum(fgdi));
    mult #(.W(W*2+1)) inst_2 (.x({(W+1)'b0, b}), .y(fgdi), .out(part2));

    mult #(.W(W)) inst_dh (.x(i_array[1][0]), .y(i_array[2][1]), .out(dh));
    mult #(.W(W)) inst_eg (.x(i_array[1][1]), .y(i_array[2][0]), .out(eg));
    adder #(.W(W*2)) inst_dheg (.x(dh), .y(eg), .sub(1'b1), .sum(dheg));
    mult #(.W(W*2+1)) inst_3 (.x({(W+1)'b0, c}), .y(dheg), .out(part3));

    wire [W*3+2:0] sum1;
    adder #(.W(W*3+1)) inst_sum1 (.x(part1[W*3:0]), .y(part2[W*3:0]), .sub(1'b0), .sum(sum1));
    adder #(.W(W*3+2)) inst_sum2 (.x(sum1), .y(part3[W*3:0]), .sub(1'b0), .sum(o_det));

endmodule: 3b3_det

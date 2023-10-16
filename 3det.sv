module fip_32_3b3_det(
    input signed [31:0] i_array [2:0][2:0],
    output signed [31:0] o_det,
    output reg overflow
);

    /*
    |a b c|
    |d e f|
    |g h i|
    det = a(ei-fh) + b(fg-di) + c(dh-eg)
    o_det = part1 + part2 + part3
    */
    wire signed [31:0] a = i_array[0][0];
    wire signed [31:0] b = i_array[0][1];
    wire signed [31:0] c = i_array[0][2];

    // Intermediate results
    logic signed [31:0] ei, fh, fg, di, dh, eg;    
    logic signed [31:0] part1, part2, part3;

    // Overflows for intermediates
    logic of1, of2, of3, of4, of5, of6, of7, of8, of9;

    /* Using 32-bit fixed-point multiplier, with bit shift and overflow 
    detection, for each intermediate */
    fip_32_mult inst_ei (.x(i_array[1][1]), .y(i_array[2][2]), .prod(ei), .overflow(of1));
    fip_32_mult inst_fh (.x(i_array[1][2]), .y(i_array[2][1]), .prod(fh), .overflow(of2));
    fip_32_mult inst_fg (.x(i_array[1][2]), .y(i_array[2][0]), .prod(fg), .overflow(of3));
    fip_32_mult inst_di (.x(i_array[1][0]), .y(i_array[2][2]), .prod(di), .overflow(of4));
    fip_32_mult inst_dh (.x(i_array[1][0]), .y(i_array[2][1]), .prod(dh), .overflow(of5));
    fip_32_mult inst_eg (.x(i_array[1][1]), .y(i_array[2][0]), .prod(eg), .overflow(of6));

    // Compose each part of the final determinant
    logic [31:0] inter1, inter2, inter3;

    
    assign inter1 = ei - fh;
    assign inter2 = fg - di;
    assign inter3 = dh - eg;

    fip_32_mult inst_inter1 (.x(a), .y(inter1), .prod(part1), .overflow(of7));
    fip_32_mult inst_inter2 (.x(b), .y(inter2), .prod(part2), .overflow(of8));
    fip_32_mult inst_inter3 (.x(c), .y(inter3), .prod(part3), .overflow(of9));
    // assign part1 = a * (ei - fh);
    // assign part2 = b * (fg - di);
    // assign part3 = c * (dh - eg);

    // Sum intermediate determinant components
    assign o_det = part1 + part2 + part3;
    assign overflow = (of1 | of2 | of3 | of4 | of5 | of6 | of7 | of8 | of9);

endmodule

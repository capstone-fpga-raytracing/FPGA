module fip_32_3b3_det(
    input [31:0] i_array [2:0][2:0],
    output [31:0] o_det;
    output reg overflow;
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
    wire [32:0] ei, fh, fg, di, dh, eg;    
    wire [31:0] part1, part2, part3;

    // Overflows for intermediates
    wire reg of1, of2, of3, of4, of5, of6;

    /* Using 32-bit fixed-point multiplier, with bit shift and overflow 
    detection, for each intermediate */
    fip_32_mult inst_ei (.x(i_array[1][1]), .y(i_array[2][2]), .prod(ei), .overflow(ovf1));
    fip_32_mult inst_fh (.x(i_array[1][2]), .y(i_array[2][1]), .prod(fh), .overflow(ovf2));
    fip_32_mult inst_fg (.x(i_array[1][2]), .y(i_array[2][0]), .prod(fg), .overflow(ovf3));
    fip_32_mult inst_di (.x(i_array[1][0]), .y(i_array[2][2]), .prod(di), .overflow(ovf4));
    fip_32_mult inst_dh (.x(i_array[1][0]), .y(i_array[2][1]), .prod(dh), .overflow(ovf5));
    fip_32_mult inst_eg (.x(i_array[1][1]), .y(i_array[2][0]), .prod(eg), .overflow(ovf6));

    // Compose each part of the final determinant
    part1 = a * (ei - fh);
    part2 = b * (fg - di);
    part3 = c * (dh - eg);

    // Sum intermediate determinant components
    assign o_det = part1 + part2 + part3;

    always @(*) begin // Set overflow if any of the overflow flags were tripped
        overflow_detected = of1 | of2 | of3 | of4 | of5 | of6;
    end

endmodule: 3b3_det

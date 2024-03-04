// basic fip operations, rtl

// overflow ignored
module fip_32_mult #(
    parameter FRA_BITS = 16
)(
    input signed [31:0] i_x,
    input signed [31:0] i_y,
    output signed [31:0] o_z
);
    logic signed [63:0] temp_z;
    assign temp_z = i_x * i_y;
    assign o_z = temp_z[FRA_BITS+31:FRA_BITS];

endmodule: fip_32_mult

// overflow & underflow ignored
module fip_32_div #(
    parameter FRA_BITS = 16
)(
    input signed [31:0] i_x,
    input signed [31:0] i_y,
    output signed [31:0] o_z
);
    logic signed [FRA_BITS+31:0] temp_x, temp_z;
    assign temp_x = i_x << FRA_BITS;
    assign temp_z = temp_x / i_y;
    assign o_z = temp_z[31:0];

endmodule: fip_32_div

module fip_32_3b3_det(
    input i_clk,
    input i_rstn,
    input i_en,
    input signed [0:2][0:2][31:0] i_array, // could be row or column vectors
    output logic signed [31:0] o_det
);

    /*
    assume inputs are row vectors (actually doesn't matter)
    |a b c|
    |d e f|
    |g h i|
    det = a(ei-fh) + b(fg-di) + c(dh-eg)
    o_det = part1 + part2 + part3
    */

    /*
    procedure of det:
    mult -> sub -> mult -> add -> add
    */

    // Intermediate results
    logic signed [31:0] ei, fh, fg, di, dh, eg;

    // Uses 32-bit fixed-point multiplier for each intermediate
    fip_32_mult mult_ei_inst (.i_x(i_array[1][1]), .i_y(i_array[2][2]), .o_z(ei));
    fip_32_mult mult_fh_inst (.i_x(i_array[1][2]), .i_y(i_array[2][1]), .o_z(fh));
    fip_32_mult mult_fg_inst (.i_x(i_array[1][2]), .i_y(i_array[2][0]), .o_z(fg));
    fip_32_mult mult_di_inst (.i_x(i_array[1][0]), .i_y(i_array[2][2]), .o_z(di));
    fip_32_mult mult_dh_inst (.i_x(i_array[1][0]), .i_y(i_array[2][1]), .o_z(dh));
    fip_32_mult mult_eg_inst (.i_x(i_array[1][1]), .i_y(i_array[2][0]), .o_z(eg));

    // Composes each part of the final determinant
    logic signed [31:0] inter1, inter2, inter3;
    assign inter1 = ei - fh;
    assign inter2 = fg - di;
    assign inter3 = dh - eg;

    logic signed [31:0] part1, part2, part3;
    fip_32_mult mult_inter1_inst (.i_x(i_array[0][0]), .i_y(inter1), .o_z(part1));
    fip_32_mult mult_inter2_inst (.i_x(i_array[0][1]), .i_y(inter2), .o_z(part2));
    fip_32_mult mult_inter3_inst (.i_x(i_array[0][2]), .i_y(inter3), .o_z(part3));

    // Sums intermediate determinant components
    logic signed [31:0] sum1;
    assign sum1 = part1 + part2;
    assign o_det = sum1 + part3;

endmodule: fip_32_3b3_det

module fip_32_vector_cross(
    input i_clk,
    input i_rstn,
    input i_en,
    input signed [0:1][0:2][31:0] i_array, // i_array[0] for vector 0
    output logic signed [0:2][31:0] o_prod
);
    /*
    i_array[0]: |a b c|
    i_array[1]: |d e f|

    o_product = |bf-ce cd-af ae-bd|
    */

    /*
    procedure of cross:
    mult -> sub
    */

    logic signed [31:0] bf, ce, cd, af, ae, bd;
    fip_32_mult mult_bf_inst (.i_x(i_array[0][1]), .i_y(i_array[1][2]), .o_z(bf));
    fip_32_mult mult_ce_inst (.i_x(i_array[0][2]), .i_y(i_array[1][1]), .o_z(ce));
    fip_32_mult mult_cd_inst (.i_x(i_array[0][2]), .i_y(i_array[1][0]), .o_z(cd));
    fip_32_mult mult_af_inst (.i_x(i_array[0][0]), .i_y(i_array[1][2]), .o_z(af));
    fip_32_mult mult_ae_inst (.i_x(i_array[0][0]), .i_y(i_array[1][1]), .o_z(ae));
    fip_32_mult mult_bd_inst (.i_x(i_array[0][1]), .i_y(i_array[1][0]), .o_z(bd));

    assign o_prod[0] = bf - ce;
    assign o_prod[1] = cd - af;
    assign o_prod[2] = ae - bd;

endmodule: fip_32_vector_cross

module fip_32_vector_normal(
    input i_clk,
    input i_rstn,
    input i_en,
    input signed [0:2][31:0] i_vector,
    output logic signed [0:2][31:0] o_vector
);

    /*
    procedure of normal:
    mult -> add -> add -> sqrt -> div
    */

    logic signed [31:0] square1, square2, square3;
    fip_32_mult mult_1_inst (.i_x(i_vector[0]), .i_y(i_vector[0]), .o_z(square1));
    fip_32_mult mult_2_inst (.i_x(i_vector[1]), .i_y(i_vector[1]), .o_z(square2));
    fip_32_mult mult_3_inst (.i_x(i_vector[2]), .i_y(i_vector[2]), .o_z(square3));

    logic signed [31:0] sum1, sum2;
    assign sum1 = square1 + square2;
    assign sum2 = sum1 + square3;

    logic signed [31:0] sqrt_sum2;
    // TO DO: add sqrt logic

    fip_32_div div_1_inst (.i_x(i_vector[0]), .i_y(sqrt_sum2), .o_z(o_vector[0]));
    fip_32_div div_2_inst (.i_x(i_vector[1]), .i_y(sqrt_sum2), .o_z(o_vector[1]));
    fip_32_div div_3_inst (.i_x(i_vector[2]), .i_y(sqrt_sum2), .o_z(o_vector[2]));

endmodule: fip_32_vector_normal

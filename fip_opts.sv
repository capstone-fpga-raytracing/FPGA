// basic fip operations, rtl

`define TRUE 1
`define FALSE 0
`define FIP_MIN 32'sh80000000
`define FIP_MAX 32'sh7fffffff

// overflow cut
module fip_32_add_sat (
    input signed [31:0] i_x,
    input signed [31:0] i_y,
    output logic signed [31:0] o_z
);
    logic signed [32:0] temp_z;
    always_comb begin
        temp_z = i_x + i_y;
        o_z = temp_z[31:0];
        if (temp_z < `FIP_MIN) o_z = `FIP_MIN;
        else if (temp_z > `FIP_MAX) o_z = `FIP_MAX;
    end
endmodule: fip_32_add_sat

// overflow ignored
module fip_32_mult #(
    parameter FRA_BITS = 16
)(
    input signed [31:0] i_x,
    input signed [31:0] i_y,
    output logic signed [31:0] o_z
);
    logic signed [63:0] temp_z;
    assign temp_z = i_x * i_y;
    assign o_z = temp_z[FRA_BITS+31:FRA_BITS];

endmodule: fip_32_mult

// overflow & underflow ignored if !SAT, else cut
module fip_32_div #(
    parameter SAT = `FALSE,
    parameter FRA_BITS = 16
)(
    input signed [31:0] i_x,
    input signed [31:0] i_y,
    output logic signed [31:0] o_z
);
    logic signed [FRA_BITS+31:0] temp_x, temp_z;
    always_comb begin
        temp_x = i_x << FRA_BITS;
        temp_z = temp_x / i_y;
        o_z = temp_z[31:0];
        if(SAT == `TRUE) begin
            if (temp_z < `FIP_MIN) o_z = `FIP_MIN;
            else if (temp_z > `FIP_MAX) o_z = `FIP_MAX;
        end
    end

endmodule: fip_32_div

module fip_32_3b3_det(
    input i_clk,
    input i_rstn,
    input i_en,
    input signed [0:2][0:2][31:0] i_array, // could be row or column vectors
    output logic signed [31:0] o_det,
    output logic o_valid // pipeline stage valid
);

    /*
    assume inputs are row vectors (actually doesn't matter)
    |a b c|
    |d e f|
    |g h i|
    det = a(ei-fh) + b(fg-di) + c(dh-eg)
    o_det = part1 + part2 + part3
    */

    // procedure of det:
    // mult -> sub -> mult -> add -> add
    // {mult, sub} -> {mult, add, add}
    logic [0:1] valid; // stage valid bit

    // stage1
    logic signed [31:0] ei, fh, fg, di, dh, eg;
    fip_32_mult mult_ei_inst (.i_x(i_array[1][1]), .i_y(i_array[2][2]), .o_z(ei));
    fip_32_mult mult_fh_inst (.i_x(i_array[1][2]), .i_y(i_array[2][1]), .o_z(fh));
    fip_32_mult mult_fg_inst (.i_x(i_array[1][2]), .i_y(i_array[2][0]), .o_z(fg));
    fip_32_mult mult_di_inst (.i_x(i_array[1][0]), .i_y(i_array[2][2]), .o_z(di));
    fip_32_mult mult_dh_inst (.i_x(i_array[1][0]), .i_y(i_array[2][1]), .o_z(dh));
    fip_32_mult mult_eg_inst (.i_x(i_array[1][1]), .i_y(i_array[2][0]), .o_z(eg));

    logic signed [0:2][31:0] inter;
    assign inter[0] = ei - fh;
    assign inter[1] = fg - di;
    assign inter[2] = dh - eg;

    // stage1 reg
    logic signed [0:2][31:0] rout_inter;
    logic signed [0:2][31:0] rout_array0;

    // stage2
    logic signed [31:0] part1, part2, part3;
    fip_32_mult mult_inter1_inst (.i_x(rout_array0[0]), .i_y(rout_inter[0]), .o_z(part1));
    fip_32_mult mult_inter2_inst (.i_x(rout_array0[1]), .i_y(rout_inter[1]), .o_z(part2));
    fip_32_mult mult_inter3_inst (.i_x(rout_array0[2]), .i_y(rout_inter[2]), .o_z(part3));
    logic signed [31:0] det;
    assign det = part1 + part2 + part3;

    // stage2 reg
    logic signed [31:0] rout_det;

    // stage control
    always_ff@(posedge i_clk) begin: pipeline
        if (!i_rstn) begin
            rout_inter <= 'b0;
            rout_array0 <= 'b0;
            rout_det <= 'b0;
            valid <= 'b0;
        end else begin
            rout_inter <= inter;
            rout_array0 <= i_array[0];
            rout_det <= det;

            valid[1] <= valid[0];
        end
        if (i_en) valid[0] <= 1'b1;
        else valid[0] <= 1'b0;
    end

    // output
    assign o_det = rout_det;
    assign o_valid = valid[1];

endmodule: fip_32_3b3_det

/* unused
module fip_32_vector_cross(
    input i_clk,
    input i_rstn,
    input i_en,
    input signed [0:1][0:2][31:0] i_array, // i_array[0] for vector 0
    output logic signed [0:2][31:0] o_prod
);
    // i_array[0]: |a b c|
    // i_array[1]: |d e f|
    // o_product = |bf-ce cd-af ae-bd|

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

    // procedure of normal:
    // mult -> add -> add -> sqrt -> div

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
*/

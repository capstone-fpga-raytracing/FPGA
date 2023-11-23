module intersection #(
    parameter signed min_t = 0 // TO DO: CHANGE
) (
    input signed [0:2][0:2][31:0] i_triangle, // i_triangle[0] for vertex 0
    input signed [0:1][0:2][31:0] i_ray, // i_ray[0] for origin(E), i_ray[1] for direction(D)
    output logic signed [0:2][31:0] o_normal,
    output logic o_invalid, // overflow, e.g. div by 0
    output logic o_result
);

    /*
    T1 = i_triangle[1] - i_triangle[0]
    T2 = i_triangle[2] - i_triangle[0]

    |T1[0], T2[0], -D[0]|   |a|
    |T1[1], T2[1], -D[1]| x |b| = E - i_triangle[0]
    |T1[2], T2[2], -D[2]|   |t|

    coef = det(T1, T2, E - i_triangle[0])
    a = det(E - i_triangle[0], T2, -D)/coef
    b = det(T1, E - i_triangle[0], -D)/coef
    t = det(T1, T2, -D)/coef

    check: coef != 0, a >= 0, b >= 0, a + b <= 1, t >= min_t
    normal: T1 x T2 (normalized)
    */

    // preprocess
    logic signed [0:2][31:0] e_t;
    logic signed [0:2][31:0] t1;
    logic signed [0:2][31:0] t2;
    logic signed [0:2][31:0] _d;

    logic of0, of1, of2, of3, of4, of5, of6, of7, of8, of9, of10, of11;
    fip_32_sub sub_e_t_0_inst (.x(i_ray[0][0]), .y(i_triangle[0][0]), .diff(e_t[0]), .overflow(of0));
    fip_32_sub sub_e_t_1_inst (.x(i_ray[0][1]), .y(i_triangle[0][1]), .diff(e_t[1]), .overflow(of1));
    fip_32_sub sub_e_t_2_inst (.x(i_ray[0][2]), .y(i_triangle[0][2]), .diff(e_t[2]), .overflow(of2));
    fip_32_sub sub_t1_0_inst (.x(i_triangle[1][0]), .y(i_triangle[0][0]), .diff(t1[0]), .overflow(of3));
    fip_32_sub sub_t1_1_inst (.x(i_triangle[1][1]), .y(i_triangle[0][1]), .diff(t1[1]), .overflow(of4));
    fip_32_sub sub_t1_2_inst (.x(i_triangle[1][2]), .y(i_triangle[0][2]), .diff(t1[2]), .overflow(of5));
    fip_32_sub sub_t2_0_inst (.x(i_triangle[2][0]), .y(i_triangle[0][0]), .diff(t2[0]), .overflow(of6));
    fip_32_sub sub_t2_1_inst (.x(i_triangle[2][1]), .y(i_triangle[0][1]), .diff(t2[1]), .overflow(of7));
    fip_32_sub sub_t2_2_inst (.x(i_triangle[2][2]), .y(i_triangle[0][2]), .diff(t2[2]), .overflow(of8));
    fip_32_sub sub__d_0_inst (.x('d0), .y(i_ray[1][0]), .diff(_d[0]), .overflow(of9));
    fip_32_sub sub__d_1_inst (.x('d0), .y(i_ray[1][1]), .diff(_d[1]), .overflow(of10));
    fip_32_sub sub__d_2_inst (.x('d0), .y(i_ray[1][2]), .diff(_d[2]), .overflow(of11));

    // a, b, t
    logic of_c, of_a, of_b, of_t;
    logic signed [31:0] coef, det_a, det_b, det_t, a, b, t;
    fip_32_3b3_det det_c_inst (.i_array('{t1, t2, e_t}), .o_det(coef), .overflow(of_c));
    fip_32_3b3_det det_a_inst (.i_array('{e_t, t2, _d}), .o_det(det_a), .overflow(of_a));
    fip_32_3b3_det det_b_inst (.i_array('{t1, e_t, _d}), .o_det(det_b), .overflow(of_b));
    fip_32_3b3_det det_t_inst (.i_array('{t1, t2, _d}), .o_det(det_t), .overflow(of_t));

    logic d_of_a, d_of_b, d_of_t, d_uf_a, d_uf_b, d_uf_t;
    fip_32_div div_a_inst (.dividend(det_a), .divisor(coef), .quotient(a), .overflow(d_of_a), .underflow(d_uf_a));
    fip_32_div div_b_inst (.dividend(det_b), .divisor(coef), .quotient(b), .overflow(d_of_b), .underflow(d_uf_b));
    fip_32_div div_t_inst (.dividend(det_t), .divisor(coef), .quotient(t), .overflow(d_of_t), .underflow(d_uf_t));

    // normal
    logic signed [0:2][31:0] cross_product, normal;
    logic of_cross, n_invalid;
    fip_32_vector_cross cross_inst (.i_array('{t1, t2}), .o_product(cross_product), .o_overflow(of_cross));

    // ignore normalize for now
    //fip_32_vector_normal normal_inst (.i_vector(cross_product), .o_vector(normal), .o_invalid(n_invalid));
    assign normal = cross_product;
    assign n_invalid = 1'b0;

    logic signed [31:0] anb;
    logic of_anb;
    fip_32_adder adder_anb_inst (.x(a), .y(b), .sum(anb), .overflow(of_anb));

    // output
    always_comb begin
        o_invalid = (of1 | of2 | of3 | of4 | of5 | of6 | of7 | of8 | of9 | of10 | of11 | of_c | of_a | of_b |
                     of_t | d_of_a | d_of_b | d_of_t | d_uf_a | d_uf_b | d_uf_t | of_cross | n_invalid | of_anb);
        if (a[31] == 0 && b[31] == 0 && anb <= 32'sh00010000 && t >= min_t) begin
            o_result = 1'b1;
            o_normal = normal;
        end else begin
            o_result = 1'b0;
            //o_normal = 'sb0;
        end
    end

endmodule: intersection

module intersection #(
    parameter signed min_t = 0 // TO DO: CHANGE
) (
    input signed [31:0] i_triangle[2:0][2:0],
    input signed [31:0] i_ray[1:0][2:0], // [1] for origin, [0] for direction
    //output logic signed [31:0] o_normal[2:0],
    output logic o_invalid, // overflow, div by 0
    output logic o_result // 1 for true, 0 for false
);
/*
param:
    min_t

input:
    triangle: corner[2], corner[1], corner[0] (3 3d-vectors)
    ray: origin(E), direction(D) (2 3d-vectors)

alg:
    T1 = corner[1] - corner[0]
    T2 = corner[2] - corner[0]

    |T1[0], T2[0], -D[0]|   |a|
    |T1[1], T2[1], -D[1]| x |b| = E - corner[0]
    |T1[2], T2[2], -D[2]|   |t|

    coef = det(T1, T2, E - corner[0])
    a = det(E - corner[0], T2, -D)/coef
    b = det(T1, E - corner[0], -D)/coef
    c = det(T1, T2, -D)/coef

    check: coef != 0, a >= 0, b >= 0, a + b <= 1, t >= min_t
    normal: ?
*/

    logic signed [31:0] e_c[2:0];
    logic signed [31:0] t1[2:0];
    logic signed [31:0] t2[2:0];
    logic signed [31:0] _d[2:0];

    logic signed [31:0] array[2:0][2:0];
    logic signed [31:0] array_a[2:0][2:0];
    logic signed [31:0] array_b[2:0][2:0];
    logic signed [31:0] array_t[2:0][2:0];

    // TO DO: overflow detection in adders
    always_comb begin
        e_c = '{i_ray[1][0]-i_triangle[0][0], i_ray[1][1]-i_triangle[0][1], i_ray[1][2]-i_triangle[0][2]};
        t1 = '{i_triangle[1][0]-i_triangle[0][0], i_triangle[1][1]-i_triangle[0][1], i_triangle[1][2]-i_triangle[0][2]};
        t2 = '{i_triangle[2][0]-i_triangle[0][0], i_triangle[2][1]-i_triangle[0][1], i_triangle[2][2]-i_triangle[0][2]};
        _d = '{0-i_ray[0][0], 0-i_ray[0][1], 0-i_ray[0][2]};
        array = '{t1, t2, e_c};
        array_a = '{e_c, t2, _d};
        array_b = '{t1, e_c, _d};
        array_t = '{t1, t2, e_c};
    end

    logic of, of_a, of_b, of_t;
    logic signed [31:0] coef, det_a, det_b, det_t, a, b, t;
    fip_32_3b3_det det_inst (.i_array(array), .o_det(coef), .overflow(of));
    fip_32_3b3_det det_a_inst (.i_array(array_a), .o_det(det_a), .overflow(of_a));
    fip_32_3b3_det det_b_inst (.i_array(array_b), .o_det(det_b), .overflow(of_b));
    fip_32_3b3_det det_t_inst (.i_array(array_t), .o_det(det_t), .overflow(of_t));

    logic d_of_a, d_of_b, d_of_t, d_uf_a, d_uf_b, d_uf_t;
    fip_32_div div_a_inst (.dividend(det_a), .divisor(coef), .quotient(a), .overflow(d_of_a), .underflow(d_uf_a));
    fip_32_div div_b_inst (.dividend(det_b), .divisor(coef), .quotient(b), .overflow(d_of_b), .underflow(d_uf_b));
    fip_32_div div_t_inst (.dividend(det_t), .divisor(coef), .quotient(t), .overflow(d_of_t), .underflow(d_uf_t));

    always_comb begin
        o_invalid = (of | of_a | of_b | of_t | d_of_a | d_of_b | d_of_t | d_uf_a | d_uf_b | d_uf_t);
        if (a[31] == 0 && b[31] == 0 && a + b <= 2'sd1 && t >= min_t) o_result = 1'b1;
        else o_result = 1'b0;
    end

    // TO DO: normal

endmodule

module intersect #(
    parameter signed min_t = /**/
) (
    input signed [31:0] i_triangle[2:0][2:0],
    input signed [31:0] i_ray[1:0][2:0], // [1] for origin, [0] for direction
    //output signed [31:0] o_normal[2:0],
    output logic o_overflow,
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

    a = det(E - corner[0], T2, -D)
    b = det(T1, E - corner[0], -D)
    c = det(T1, T2, -D)
    check: a >= 0, b >= 0, a + b <= 1, t >= min_t
    normal: ?
*/

    logic signed [31:0] a, b, t;
    logic signed [31:0] e_c[2:0];
    logic signed [31:0] t1[2:0];
    logic signed [31:0] t2[2:0];

    logic signed [31:0] array_a[2:0][2:0];
    logic signed [31:0] array_b[2:0][2:0];
    logic signed [31:0] array_c[2:0][2:0];

    // TO DO: overflow detection?
    always_comb begin
        e_c = '{i_ray[1][2]-i_triangle[0][2], i_ray[1][1]-i_triangle[0][1], i_ray[1][0]-i_triangle[0][0]};
        t1 = '{i_triangle[1][2]-i_triangle[0][2], i_triangle[1][1]-i_triangle[0][1], i_triangle[1][0]-i_triangle[0][0]};
        t2 = '{i_triangle[2][2]-i_triangle[0][2], i_triangle[2][1]-i_triangle[0][1], i_triangle[2][0]-i_triangle[0][0]};
        _d = '{0-i_ray[0][2], 0-i_ray[0][1], 0-i_ray[0][0]};
        array_a = '{_d, t2, e_c};
        array_b = '{t1, e_c, _d};
        array_t = '{t1, t2, _d};
    end

    logic of_a, of_b, of_t;
    fip_32_3b3_det det_a (.i_array(array_a), .o_det(a), .overflow(of_a));
    fip_32_3b3_det det_b (.i_array(array_b), .o_det(b), .overflow(of_b));
    fip_32_3b3_det det_t (.i_array(array_t), .o_det(t), .overflow(of_t));

    always_comb begin
        o_overflow = (of_a | of_b | of_t);
        if (a[31] == 0 && b[31] == 0 && a + b <= 2'sd1 && t >= min_t) o_result = 1'b1;
        else o_result = 1'b1;
    end

    // TO DO: normal

endmodule

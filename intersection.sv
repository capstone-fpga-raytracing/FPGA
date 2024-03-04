// intersection modules

// basic intersection
module intersection #(
    parameter signed min_t = 0
) (
    input i_clk,
    input i_rstn,
    input i_en,
    input signed [0:2][0:2][31:0] i_tri, // i_tri[0] for vertex 0
    input signed [0:1][0:2][31:0] i_ray, // i_ray[0] for origin(E), i_ray[1] for direction(D)
    output logic signed [0:2][31:0] o_normal,
    output logic o_result
);

    /*
    T1 = i_tri[1] - i_tri[0]
    T2 = i_tri[2] - i_tri[0]

    |T1[0], T2[0], -D[0]|   |a|
    |T1[1], T2[1], -D[1]| x |b| = E - i_tri[0]
    |T1[2], T2[2], -D[2]|   |t|

    coef = det(T1, T2, E - i_tri[0])
    a = det(E - i_tri[0], T2, -D)/coef
    b = det(T1, E - i_tri[0], -D)/coef
    t = det(T1, T2, -D)/coef

    check: coef != 0, a >= 0, b >= 0, a + b <= 1, t >= min_t
    normal: T1 x T2 (normalized)
    */

    // preprocess
    logic signed [0:2][31:0] e_t;
    logic signed [0:2][31:0] t1;
    logic signed [0:2][31:0] t2;
    logic signed [0:2][31:0] _d;

    always_comb begin
        e_t[0] = i_ray[0][0] - i_tri[0][0];
        e_t[1] = i_ray[0][1] - i_tri[0][1];
        e_t[2] = i_ray[0][2] - i_tri[0][2];

        t1[0] = i_tri[1][0] - i_tri[0][0];
        t1[1] = i_tri[1][1] - i_tri[0][1];
        t1[2] = i_tri[1][2] - i_tri[0][2];

        t2[0] = i_tri[2][0] - i_tri[0][0];
        t2[1] = i_tri[2][1] - i_tri[0][1];
        t2[2] = i_tri[2][2] - i_tri[0][2];

        _d[0] = 32'b0 - i_ray[1][0];
        _d[1] = 32'b0 - i_ray[1][1];
        _d[2] = 32'b0 - i_ray[1][2];
    end

    // a, b, t
    logic signed [31:0] coef, det_a, det_b, det_t, a, b, t;
    fip_32_3b3_det det_c_inst (.i_clk(i_clk), .i_rstn(i_rstn), .i_en(i_en), .i_array('{t1, t2, e_t}), .o_det(coef));
    fip_32_3b3_det det_a_inst (.i_clk(i_clk), .i_rstn(i_rstn), .i_en(i_en), .i_array('{e_t, t2, _d}), .o_det(det_a));
    fip_32_3b3_det det_b_inst (.i_clk(i_clk), .i_rstn(i_rstn), .i_en(i_en), .i_array('{t1, e_t, _d}), .o_det(det_b));
    fip_32_3b3_det det_t_inst (.i_clk(i_clk), .i_rstn(i_rstn), .i_en(i_en), .i_array('{t1, t2, _d}), .o_det(det_t));

    fip_32_div div_a_inst (.i_x(det_a), .i_y(coef), .o_z(a));
    fip_32_div div_b_inst (.i_x(det_b), .i_y(coef), .o_z(b));
    fip_32_div div_t_inst (.i_x(det_t), .i_y(coef), .o_z(t));

    // normal
    logic signed [0:2][31:0] cross_prod, normal;
    fip_32_vector_cross cross_inst (.i_clk(i_clk), .i_rstn(i_rstn), .i_en(i_en), .i_array('{t1, t2}), .o_prod(cross_prod));

    // ignore normalize for now
    //fip_32_vector_normal normal_inst (.i_clk(i_clk), .i_rstn(i_rstn), .i_en(i_en), .i_vector(cross_prod), .o_vector(normal));
    assign normal = cross_prod;

    logic signed [31:0] anb;
    assign anb = a + b;

    // output
    always_comb begin
        o_normal = normal;
        if (a[31] == 0 && b[31] == 0 && anb <= 32'sh00010000 && t >= min_t) begin
            o_result = 1'b1;
        end else begin
            o_result = 1'b0;
        end
    end

endmodule: intersection


// TO DO: pipelined intersection
module pl_intersection #(
    parameter signed min_t = 0
) (
    input i_clk,
    input i_rstn,
    input i_en,
    input signed [0:2][0:2][31:0] i_tri, // i_tri[0] for vertex 0
    input signed [0:1][0:2][31:0] i_ray, // i_ray[0] for origin(E), i_ray[1] for direction(D)
    output logic signed [0:2][31:0] o_normal,
    output logic o_result
);

    /*
    procedure of intersection:
    sub -> cross (-> normal)
        -> det -> add
               -> div
    */

    // preprocess
    logic signed [0:2][31:0] e_t;
    logic signed [0:2][31:0] t1;
    logic signed [0:2][31:0] t2;
    logic signed [0:2][31:0] _d;

    always_comb begin
        e_t[0] = i_ray[0][0] - i_tri[0][0];
        e_t[1] = i_ray[0][1] - i_tri[0][1];
        e_t[2] = i_ray[0][2] - i_tri[0][2];

        t1[0] = i_tri[1][0] - i_tri[0][0];
        t1[1] = i_tri[1][1] - i_tri[0][1];
        t1[2] = i_tri[1][2] - i_tri[0][2];

        t2[0] = i_tri[2][0] - i_tri[0][0];
        t2[1] = i_tri[2][1] - i_tri[0][1];
        t2[2] = i_tri[2][2] - i_tri[0][2];

        _d[0] = 32'b0 - i_ray[1][0];
        _d[1] = 32'b0 - i_ray[1][1];
        _d[2] = 32'b0 - i_ray[1][2];
    end

    // a, b, t
    logic signed [31:0] coef, det_a, det_b, det_t, a, b, t;
    fip_32_3b3_det det_c_inst (.i_clk(i_clk), .i_rstn(i_rstn), .i_en(i_en), .i_array('{t1, t2, e_t}), .o_det(coef));
    fip_32_3b3_det det_a_inst (.i_clk(i_clk), .i_rstn(i_rstn), .i_en(i_en), .i_array('{e_t, t2, _d}), .o_det(det_a));
    fip_32_3b3_det det_b_inst (.i_clk(i_clk), .i_rstn(i_rstn), .i_en(i_en), .i_array('{t1, e_t, _d}), .o_det(det_b));
    fip_32_3b3_det det_t_inst (.i_clk(i_clk), .i_rstn(i_rstn), .i_en(i_en), .i_array('{t1, t2, _d}), .o_det(det_t));

    fip_32_div div_a_inst (.i_x(det_a), .i_y(coef), .o_z(a));
    fip_32_div div_b_inst (.i_x(det_b), .i_y(coef), .o_z(b));
    fip_32_div div_t_inst (.i_x(det_t), .i_y(coef), .o_z(t));

    // normal
    logic signed [0:2][31:0] cross_prod, normal;
    fip_32_vector_cross cross_inst (.i_clk(i_clk), .i_rstn(i_rstn), .i_en(i_en), .i_array('{t1, t2}), .o_prod(cross_prod));

    // ignore normalize for now
    //fip_32_vector_normal normal_inst (.i_clk(i_clk), .i_rstn(i_rstn), .i_en(i_en), .i_vector(cross_prod), .o_vector(normal));
    assign normal = cross_prod;

    logic signed [31:0] anb;
    assign anb = a + b;

    // output
    always_comb begin
        o_normal = normal;
        if (a[31] == 0 && b[31] == 0 && anb <= 32'sh00010000 && t >= min_t) begin
            o_result = 1'b1;
        end else begin
            o_result = 1'b0;
        end
    end

endmodule: pl_intersection


// fake intersection, for test only
module dummy_intersection #(
    parameter signed min_t = 0
) (
    input i_clk,
    input i_rstn,
    input i_en,
    input signed [0:2][0:2][31:0] i_triangle, // i_triangle[0] for vertex 0
    input signed [0:1][0:2][31:0] i_ray, // i_ray[0] for origin(E), i_ray[1] for direction(D)
    output logic signed [0:2][31:0] o_normal,
    output logic o_result
);

assign o_normal[0] = 'h00010002;
assign o_normal[1] = 'h00030004;
assign o_normal[2] = 'h00050006;
assign o_result = 1'b1;

endmodule: dummy_intersection

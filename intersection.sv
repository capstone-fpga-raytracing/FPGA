// intersection modules

`define FIP_ONE 32'sh00010000


// pipelined intersection
module intersection #(
    parameter signed min_t = 0
) (
    input i_clk,
    input i_rstn,
    input i_en,
    input signed [0:2][0:2][31:0] i_tri, // i_tri[0] for vertex 0
    input signed [0:1][0:2][31:0] i_ray, // i_ray[0] for origin(E), i_ray[1] for direction(D)
    output logic signed [31:0] o_t,
    output logic o_result,
    output logic o_valid // pipeline stage valid
);

    // procedure of intersection:
    // sub -> det -> add -> div
    // {sub} -> {det} -> {add, div}
    logic [0:1] valid; // stage valid bit
    logic i_valid; // submodule output

    // stage1: preprocess
    logic signed [0:2][31:0] e_t, t1, t2, _d;

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

    // stage1 reg
    logic signed [0:2][31:0] rout_e_t, rout_t1, rout_t2, rout__d;

    // stage2 (multi): det
    logic signed [31:0] coef, det_a, det_b, det_t;
    logic drop; // all 4 det modules are working parallelly, so keep only one o_valid
    fip_32_3b3_det det_c_inst (.i_clk(i_clk), .i_rstn(i_rstn), .i_en(valid[0]),
                               .i_array('{rout_t1, rout_t2, rout_e_t}), .o_det(coef), .o_valid(i_valid));
    fip_32_3b3_det det_a_inst (.i_clk(i_clk), .i_rstn(i_rstn), .i_en(valid[0]),
                               .i_array('{rout_e_t, rout_t2, rout__d}), .o_det(det_a), .o_valid(drop));
    fip_32_3b3_det det_b_inst (.i_clk(i_clk), .i_rstn(i_rstn), .i_en(valid[0]),
                               .i_array('{rout_t1, rout_e_t, rout__d}), .o_det(det_b), .o_valid(drop));
    fip_32_3b3_det det_t_inst (.i_clk(i_clk), .i_rstn(i_rstn), .i_en(valid[0]),
                               .i_array('{rout_t1, rout_t2, rout__d}), .o_det(det_t), .o_valid(drop));

    // stage3: result
    logic signed [31:0] a, b, t;
    fip_32_div #(.SAT(1)) div_a_inst (.i_x(det_a), .i_y(coef), .o_z(a));
    fip_32_div #(.SAT(1)) div_b_inst (.i_x(det_b), .i_y(coef), .o_z(b));
    fip_32_div #(.SAT(1)) div_t_inst (.i_x(det_t), .i_y(coef), .o_z(t));
    logic signed [31:0] anb;
    fip_32_add_sat add_sat_inst (.i_x(a), .i_y(b), .o_z(anb));
    logic result;
    always_comb begin
        result = 1'b0;
        if (a[31] == 0 && b[31] == 0 && anb <= `FIP_ONE && t >= min_t) result = 1'b1;
    end

    // stage3 reg
    logic signed [31:0] rout_t;
    logic rout_result;

    // stage control
    always_ff@(posedge i_clk) begin: pipeline
        if (!i_rstn) begin
            rout_e_t <= 'b0;
            rout_t1 <= 'b0;
            rout_t2 <= 'b0;
            rout__d <= 'b0;
            rout_t <= 'b0;
            rout_result <= 'b0;
            valid <= 'b0;
        end else begin
            rout_e_t <= e_t;
            rout_t1 <= t1;
            rout_t2 <= t2;
            rout__d <= _d;
            rout_result <= result;
            rout_t <= t;

            // valid[0] goes to i_valid in det submodules
            valid[1] <= i_valid;
        end
        if (i_en) valid[0] <= 1'b1;
        else valid[0] <= 1'b0;
    end

    // output
    assign o_t = rout_t;
    assign o_result = rout_result;
    assign o_valid = valid[1];

endmodule: intersection


// basic intersection (without pipeline)
module bs_intersection #(
    parameter signed min_t = 0
) (
    input i_clk, // unused
    input i_rstn, // unused
    input i_en, // unused
    input signed [0:2][0:2][31:0] i_tri, // i_tri[0] for vertex 0
    input signed [0:1][0:2][31:0] i_ray, // i_ray[0] for origin(E), i_ray[1] for direction(D)
    output logic signed [31:0] o_t,
    output logic o_result,
    output logic o_valid // punused
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

    // det
    logic signed [31:0] coef, det_a, det_b, det_t;
    fip_32_3b3_det det_c_inst (.i_clk(i_clk), .i_rstn(i_rstn), .i_en(i_en), .i_array('{t1, t2, e_t}), .o_det(coef));
    fip_32_3b3_det det_a_inst (.i_clk(i_clk), .i_rstn(i_rstn), .i_en(i_en), .i_array('{e_t, t2, _d}), .o_det(det_a));
    fip_32_3b3_det det_b_inst (.i_clk(i_clk), .i_rstn(i_rstn), .i_en(i_en), .i_array('{t1, e_t, _d}), .o_det(det_b));
    fip_32_3b3_det det_t_inst (.i_clk(i_clk), .i_rstn(i_rstn), .i_en(i_en), .i_array('{t1, t2, _d}), .o_det(det_t));

    logic signed [31:0] a, b, t;
    fip_32_div #(.SAT(1)) div_a_inst (.i_x(det_a), .i_y(coef), .o_z(a));
    fip_32_div #(.SAT(1)) div_b_inst (.i_x(det_b), .i_y(coef), .o_z(b));
    fip_32_div #(.SAT(1)) div_t_inst (.i_x(det_t), .i_y(coef), .o_z(t));

    // normal
    //logic signed [0:2][31:0] cross_prod, normal;
    //fip_32_vector_cross cross_inst (.i_clk(i_clk), .i_rstn(i_rstn), .i_en(i_en), .i_array('{t1, t2}), .o_prod(cross_prod));

    // ignore normalize for now
    //fip_32_vector_normal normal_inst (.i_clk(i_clk), .i_rstn(i_rstn), .i_en(i_en), .i_vector(cross_prod), .o_vector(normal));
    //assign normal = cross_prod;

    logic signed [31:0] anb;
    fip_32_add_sat add_sat_inst (.i_x(a), .i_y(b), .o_z(anb));

    // result
    always_comb begin
        o_t = t;
        o_result = 1'b0;
        if (a[31] == 0 && b[31] == 0 && anb <= `FIP_ONE && t >= min_t) o_result = 1'b1;
    end

endmodule: bs_intersection


// fake intersection, for test only
module dummy_intersection #(
    parameter signed min_t = 0
) (
    input i_clk,
    input i_rstn,
    input i_en,
    input signed [0:2][0:2][31:0] i_tri, // i_tri[0] for vertex 0
    input signed [0:1][0:2][31:0] i_ray, // i_ray[0] for origin(E), i_ray[1] for direction(D)
    output logic signed [31:0] o_t,
    output logic o_result,
    output logic o_valid // pipeline stage valid
);

    assign o_t = 'h00010002;
    assign o_result = 'b1;
    assign o_valid = 'b1;

endmodule: dummy_intersection

module fip_32_adder(
    input signed [31:0] x,
    input signed [31:0] y,
    output reg signed [31:0] sum,
    output reg overflow
);
    parameter integer_bits = 16;
    parameter fractional_bits = 16;

    parameter MAX_VALUE = (2**(integer_bits-1) - 1) << fractional_bits; // 32'h7FFFFFFF
    parameter MIN_VALUE = -(2**(integer_bits-1)) << fractional_bits; // 32'h80000000


    always_comb begin
        overflow = 0; // Initialization

        sum = x + y;

        if (sum > MAX_VALUE || sum < MIN_VALUE)
            overflow = 1'b1;
        else
            overflow = 1'b0;

        if ((x > 0) && (y > 0) && (sum <= 0)) 
            overflow = 1'b1; // Overflow occurred: Positive + Positive = Negative
        else if ((x < 0) && (y < 0) && (sum >= 0)) 
            overflow = 1'b1; // Overflow occurred: Negative + Negative = Positive
    end
    
endmodule

module fip_32_sub(
    input signed [31:0] x,
    input signed [31:0] y,
    output reg signed [31:0] diff,
    output reg overflow
);
    parameter integer_bits = 16;
    parameter fractional_bits = 16;

    parameter MAX_VALUE = (2**(integer_bits-1) - 1) << fractional_bits;
    parameter MIN_VALUE = -(2**(integer_bits-1)) << fractional_bits;

    always_comb begin
        overflow = 0; // Initialization

        diff = x - y;

        // General overflow check
        if (diff > MAX_VALUE || diff < MIN_VALUE)
            overflow = 1'b1;
    end
endmodule


module fip_32_mult(
    input signed [31:0] x, 
    input signed [31:0] y,
    output signed [31:0] prod,
    output reg overflow
);
    logic signed [63:0] temp, adjusted;

    always_comb begin
        overflow = 0; // Initialization

        temp = x * y;
        adjusted = temp >>> 16;

        // check for overflow
        if (adjusted[31] == 1'b0) begin // Number should be positive, check if any sign bit is 1
            overflow = |adjusted[63:32];  // OR all bits. If 1, overflow detected.
        end else begin // Number should be negative, check if any sign bit is 0
            overflow = ~|adjusted[63:32]; // NOR: If any bit is 0, when it should be 1, overflow detected
        end

        
    end
    assign prod = adjusted[31:0];

endmodule

module fip_32_div(
    input signed [31:0] dividend,
    input signed [31:0] divisor,
    output signed [31:0] quotient,
    output reg overflow,
    output reg underflow
);

    parameter integer_bits = 16;
    parameter fractional_bits = 16;

    parameter MAX_VALUE = (2**(integer_bits-1) - 1) << fractional_bits;
    parameter MIN_VALUE = -(2**(integer_bits-1)) << fractional_bits;

    logic signed [47:0] temp_dividend;
    logic signed [47:0] res;
    assign temp_dividend = dividend << 16;
    always_comb begin
        overflow = 0; // Initialization
        underflow = 0; // Initialization
        if(divisor == 32'b0) begin
            res = 0;
            underflow = 1'b1; // Div by 0 error indicated by 1'b1 in underflow signal
        end else begin
            res = temp_dividend / divisor;
            if(res >= MAX_VALUE || res <= MIN_VALUE) begin
                overflow = 1'b1;
            end 
            else if (res[31] == 1 && (dividend[31] == divisor[31])) begin // Negative result when signs of input are same
                overflow = 1'b1;
            end
        end
    end
    assign quotient = res[31:0];

endmodule

module fip_32_3b3_det(
    input signed [0:2][0:2][31:0] i_array, // could be row or column vectors (same)
    output logic signed [31:0] o_det,
    output logic overflow
);

    /*
    assume inputs are row vectors (actually doesn't matter)
    |a b c|
    |d e f|
    |g h i|
    det = a(ei-fh) + b(fg-di) + c(dh-eg)
    o_det = part1 + part2 + part3
    */

    // Intermediate results
    logic signed [31:0] ei, fh, fg, di, dh, eg;    

    // Overflows for intermediates
    logic of1, of2, of3, of4, of5, of6, of7, of8, of9, of10, of11, of12, of13, of14;

    /* Using 32-bit fixed-point multiplier, with bit shift and overflow 
    detection, for each intermediate */
    fip_32_mult mult_ei_inst (.x(i_array[1][1]), .y(i_array[2][2]), .prod(ei), .overflow(of1));
    fip_32_mult mult_fh_inst (.x(i_array[1][2]), .y(i_array[2][1]), .prod(fh), .overflow(of2));
    fip_32_mult mult_fg_inst (.x(i_array[1][2]), .y(i_array[2][0]), .prod(fg), .overflow(of3));
    fip_32_mult mult_di_inst (.x(i_array[1][0]), .y(i_array[2][2]), .prod(di), .overflow(of4));
    fip_32_mult mult_dh_inst (.x(i_array[1][0]), .y(i_array[2][1]), .prod(dh), .overflow(of5));
    fip_32_mult mult_eg_inst (.x(i_array[1][1]), .y(i_array[2][0]), .prod(eg), .overflow(of6));

    // Compose each part of the final determinant
    logic signed [31:0] inter1, inter2, inter3;
    fip_32_sub sub_inter1_inst (.x(ei), .y(fh), .diff(inter1), .overflow(of7));
    fip_32_sub sub_inter2_inst (.x(fg), .y(di), .diff(inter2), .overflow(of8));
    fip_32_sub sub_inter3_inst (.x(dh), .y(eg), .diff(inter3), .overflow(of9));

    logic signed [31:0] part1, part2, part3;
    fip_32_mult mult_inter1_inst (.x(i_array[0][0]), .y(inter1), .prod(part1), .overflow(of10));
    fip_32_mult mult_inter2_inst (.x(i_array[0][1]), .y(inter2), .prod(part2), .overflow(of11));
    fip_32_mult mult_inter3_inst (.x(i_array[0][2]), .y(inter3), .prod(part3), .overflow(of12));

    // Sum intermediate determinant components
    logic signed [31:0] sum1;
    fip_32_adder adder_1_inst (.x(part1), .y(part2), .sum(sum1), .overflow(of13));
    fip_32_adder adder_2_inst (.x(sum1), .y(part3), .sum(o_det), .overflow(of14));

    assign overflow = (of1 | of2 | of3 | of4 | of5 | of6 | of7 | of8 | of9 | of10 | of11 | of12 | of13 | of14);

endmodule: fip_32_3b3_det

module fip_32_vector_cross(
    input signed [0:1][0:2][31:0] i_array, // i_array[0] for vector 0
    output logic signed [0:2][31:0] o_product,
    output logic o_overflow
);
    /*
    i_array[0]: |a b c|
    i_array[1]: |d e f|

    o_product = |bf-ce cd-af ae-bd|
    */

    logic signed [31:0] bf, ce, cd, af, ae, bd;
    logic of1, of2, of3, of4, of5, of6, of7, of8, of9;
    fip_32_mult mult_bf_inst (.x(i_array[0][1]), .y(i_array[1][2]), .prod(bf), .overflow(of1));
    fip_32_mult mult_ce_inst (.x(i_array[0][1]), .y(i_array[1][2]), .prod(ce), .overflow(of2));
    fip_32_mult mult_cd_inst (.x(i_array[0][1]), .y(i_array[1][2]), .prod(cd), .overflow(of3));
    fip_32_mult mult_af_inst (.x(i_array[0][1]), .y(i_array[1][2]), .prod(af), .overflow(of4));
    fip_32_mult mult_ae_inst (.x(i_array[0][1]), .y(i_array[1][2]), .prod(ae), .overflow(of5));
    fip_32_mult mult_bd_inst (.x(i_array[0][1]), .y(i_array[1][2]), .prod(bd), .overflow(of6));

    fip_32_sub sub_inter1_inst (.x(bf), .y(ce), .diff(o_product[0]), .overflow(of7));
    fip_32_sub sub_inter2_inst (.x(cd), .y(af), .diff(o_product[1]), .overflow(of8));
    fip_32_sub sub_inter3_inst (.x(ae), .y(bd), .diff(o_product[2]), .overflow(of9));

    assign o_overflow =  (of1 | of2 | of3 | of4 | of5 | of6 | of7 | of8 | of9);

endmodule: fip_32_vector_cross

module fip_32_vector_normal(
    input signed [0:2][31:0] i_vector,
    output logic signed [0:2][31:0] o_vector,
    output logic o_invalid
);

    logic signed [31:0] square1, square2, square3;
    logic of1, of2, of3, of4, of5, of6, of7, of8, of9, uf1, uf2, uf3;
    fip_32_mult mult_1_inst (.x(i_vector[0]), .y(i_vector[0]), .prod(square1), .overflow(of1));
    fip_32_mult mult_2_inst (.x(i_vector[1]), .y(i_vector[1]), .prod(square2), .overflow(of2));
    fip_32_mult mult_3_inst (.x(i_vector[2]), .y(i_vector[2]), .prod(square3), .overflow(of3));

    logic signed [31:0] sum1, sum2;
    fip_32_adder adder_1_inst (.x(square1), .y(square2), .sum(sum1), .overflow(of4));
    fip_32_adder adder_2_inst (.x(sum1), .y(square3), .sum(sum2), .overflow(of5));

    
    logic signed [31:0] sqrt_sum2;
    // TO DO: add sqrt logic

    fip_32_div div_1_inst (.dividend(i_vector[0]), .divisor(sqrt_sum2), .quotient(o_vector[0]), .overflow(of6), .underflow(uf1));
    fip_32_div div_2_inst (.dividend(i_vector[1]), .divisor(sqrt_sum2), .quotient(o_vector[1]), .overflow(of7), .underflow(uf2));
    fip_32_div div_3_inst (.dividend(i_vector[2]), .divisor(sqrt_sum2), .quotient(o_vector[2]), .overflow(of8), .underflow(uf3));

    assign o_invalid =  (of1 | of2 | of3 | of4 | of5 | of6 | of7 | of8 | uf1 | uf2 | uf3);

endmodule: fip_32_vector_normal

// basic fip operations, tb

module fip_32_mult_tb();

    parameter FRA_BITS = 16; // For Q16.16 fixed-point format

    logic signed [31:0] x, y;
    logic signed [31:0] prod;

    // Instantiate the multiplier module
    fip_32_mult #(
        .FRA_BITS(FRA_BITS)
    ) mult_inst (
        .i_x(x),
        .i_y(y),
        .o_z(prod)
    );

    initial begin
        // overflow ignored

        // Test 1: Simple multiplication without overflow
        x = 1 << FRA_BITS; // 1.0 in Q16.16 (0x00010000 or 65536 as signed integer)
        y = 1 << FRA_BITS; // 1.0 in Q16.16 (0x00010000 or 65536 as signed integer)
        #10;
        // Expected: prod = 1.0 in Q16.16 (0x00010000 or 65536 as signed integer), overflow = 0

        // Test 2: Edge case, multiplication by zero
        x = 1 << FRA_BITS; // 1.0 in Q16.16 (0x00010000 or 65536 as signed integer)
        y = 0; // 0 in Q16.16
        #10;
        // Expected: prod = 0 in Q16.16, overflow = 0

        // Test 3: Fractional multiplication without overflow
        x = 32'h00008000; // 0.5 in Q16.16 (32768 as signed integer)
        y = 32'h00008000; // 0.5 in Q16.16 (32768 as signed integer)
        #10;
        // Expected: prod = 0.25 in Q16.16 (0x00004000 or 16384 as signed integer), overflow = 0

        // Test 4: Fractional multiplication with one negative operand
        x = 32'hFFFF8000; // -0.5 in Q16.16 (-32768 as signed integer)
        y = 32'h00008000; // 0.5 in Q16.16 (32768 as signed integer)
        #10;
        // Expected: prod = -0.25 in Q16.16 (0xFFFFC000 or -16384 as signed integer), overflow = 0

        // Test 5: Small fractional multiplication without overflow
        x = 32'h00000001; // Very small positive fraction in Q16.16 (1 as signed integer)
        y = 32'h00000001; // Very small positive fraction in Q16.16 (1 as signed integer)
        #10;
        // Expected: prod is a very small positive fraction in Q16.16 (0x00000000 or 0 as signed integer), overflow = 0

        $stop;
    end

endmodule: fip_32_mult_tb

module fip_32_div_tb();

    parameter FRA_BITS = 16; // For Q16.16 fixed-point format

    logic signed [31:0] x, y;
    logic signed [31:0] quotient;

    fip_32_div #(
        .FRA_BITS(FRA_BITS)
    ) div_inst (
        .i_x(x),
        .i_y(y),
        .o_z(quotient)
    );

    initial begin
        // overflow & underflow ignored

        // Test 1: Division of integer numbers without overflow
        x = 2 << FRA_BITS; // 2.0 in Q16.16 (131072)    
        y = 2 << FRA_BITS; // 2.0 in Q16.16 (131072)
        #10;
        // Expected: quotient = 1.0 in Q16.16 (65536) with no overflow

        // Test 2: Division of fractional numbers
        x = (0.5 * (2**FRA_BITS)); // 0.5 in Q16.16 (32768)
        y = (0.25 * (2**FRA_BITS)); // 0.25 in Q16.16 (16384)
        #10;
        // Expected: quotient = 2.0 in Q16.16 (131072) with no overflow

        // Test 3: Division of small numbers
        x = 2;  // 2/65536 in Q16.16 (2)
        y = 3;  // 3/65536 in Q16.16 (3)
        #10;
        // Expected: quotient = 2/3 in Q16.16 (43708) with no underflow/overflow
        // RESULT: 43690, which is an error of 0.0002746582. Negligible.

        // Test 4: Division with negative numbers
        x = -1 << FRA_BITS; // -1.0 in Q16.16 (-65536)
        y = (0.5 * (2**FRA_BITS)); // 0.5 in Q16.16 (32768)
        #10;
        // Expected: quotient = -2.0 in Q16.16 (-131072) with no overflow

        $stop;
    end

endmodule: fip_32_div_tb

module fip_32_3b3_det_tb();

    logic signed [0:2][0:2][31:0] i_array;
    logic signed [31:0] o_det;

    fip_32_3b3_det fip_32_3b3_det_inst (
        .i_clk(1'b0),
        .i_rstn(1'b1),
        .i_en(1'b1),
        .i_array(i_array),
        .o_det(o_det)
    );

    initial begin
        // overflow ignored

        // Test 1: Determinant of an identity matrix
        i_array[0][0] = 32'h00010000; // 1 in Q16.16 (65536)
        i_array[0][1] = 32'b0;        // 0 (0)
        i_array[0][2] = 32'b0;        // 0 (0)

        i_array[1][0] = 32'b0;        // 0 (0)
        i_array[1][1] = 32'h00010000; // 1 in Q16.16 (65536)
        i_array[1][2] = 32'b0;        // 0 (0)

        i_array[2][0] = 32'b0;        // 0 (0)
        i_array[2][1] = 32'b0;        // 0 (0)
        i_array[2][2] = 32'h00010000; // 1 in Q16.16 (65536)
        #10;
        // Expected: o_det = 1 in Q16.16 (65536) with no overflow

        // Test 2: Determinant with random values
        i_array[0][0] = 32'h00010000; // 1 in Q16.16 (65536)
        i_array[0][1] = 32'h00020000; // 2 in Q16.16 (131072)
        i_array[0][2] = 32'h00030000; // 3 in Q16.16 (196608)

        i_array[1][0] = 32'h00040000; // 4 in Q16.16 (262144)
        i_array[1][1] = 32'h00050000; // 5 in Q16.16 (327680)
        i_array[1][2] = 32'h00060000; // 6 in Q16.16 (393216)

        i_array[2][0] = 32'h00070000; // 7 in Q16.16 (458752)
        i_array[2][1] = 32'h00080000; // 8 in Q16.16 (524288)
        i_array[2][2] = 32'h00090000; // 9 in Q16.16 (589824)
        #10;
        // Expected: o_det = 0 with no overflow (since the matrix is singular)

        // Test 3: Determinant with some negative values
        i_array[0][0] = 32'h00010000; // 1 in Q16.16 (65536)
        i_array[0][1] = 32'hFFFF0000; // -1 in Q16.16 (-65536)
        i_array[0][2] = 32'h00030000; // 3 in Q16.16 (196608)

        i_array[1][0] = 32'h00040000; // 4 in Q16.16 (262144)
        i_array[1][1] = 32'h00050000; // 5 in Q16.16 (327680)
        i_array[1][2] = 32'h00060000; // 6 in Q16.16 (393216)

        i_array[2][0] = 32'h00070000; // 7 in Q16.16 (458752)
        i_array[2][1] = 32'h00080000; // 8 in Q16.16 (524288)
        i_array[2][2] = 32'h00090000; // 9 in Q16.16 (589824)
        #10;
        // Expected: o_det = -18 in Q16.16 (-1179648) with no overflow
        
        $stop;
    end

endmodule: fip_32_3b3_det_tb

module fip_32_vector_cross_tb();

    logic signed [0:1][0:2][31:0] i_array;
    logic signed [0:2][31:0] o_prod;

    fip_32_vector_cross fip_32_vector_cross_inst (
        .i_clk(1'b0),
        .i_rstn(1'b1),
        .i_en(1'b1),
        .i_array(i_array),
        .o_prod(o_prod)
    );

    initial begin
        // TO DO: add test cases here
    end

endmodule: fip_32_vector_cross_tb

module fip_32_vector_normal_tb();

    logic signed [0:2][31:0] i_vector;
    logic signed [0:2][31:0] o_vector;

    fip_32_vector_normal fip_32_vector_normal_inst (
        .i_clk(1'b0),
        .i_rstn(1'b1),
        .i_en(1'b1),
        .i_vector(i_vector),
        .o_vector(o_vector)
    );

    initial begin
        // TO DO: add test cases here
    end

endmodule: fip_32_vector_normal_tb

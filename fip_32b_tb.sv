module tb_fip_32_adder();

    parameter INT_SHIFT = 16;

    reg signed [31:0] x, y;
    wire signed [31:0] sum;
    wire overflow;

    fip_32_adder adder_inst (
        .x(x),
        .y(y),
        .sum(sum),
        .overflow(overflow)
    );

    initial begin
        // Test 1: Simple addition
        x = 1 << INT_SHIFT; // 1.0 in Q16.16 (0x00010000)
        y = 1 << INT_SHIFT; // 1.0 in Q16.16 (0x00010000)
        #10;
        // Expected: sum = 2.0 in Q16.16 (0x00020000), overflow = 0

        // Test 2: Checking for positive overflow
        x = 32'h7FFFFFFF;    // Maximum positive value representable in 32 bits
        y = 1 << INT_SHIFT; // 1.0 in Q16.16 (0x00010000)
        #10;
        // Expected: overflow = 1 

        // Test 3: Addition with negative value
        x = -1 << INT_SHIFT; // -1.0 in Q16.16 (0xFFFF0000)
        y = -1;              // Fractional value of -1/65536 in Q16.16 (negative very small fraction)
        #10;
        // Expected: sum is slightly less than -1.0 in Q16.16, overflow = 0

        $stop; // End the simulation
    end

endmodule


module tb_fip_32_sub();

    parameter INT_SHIFT = 16;

    reg signed [31:0] x, y;
    wire signed [31:0] diff;
    wire overflow;

    fip_32_sub sub_inst (
        .x(x),
        .y(y),
        .diff(diff),
        .overflow(overflow)
    );

    initial begin
        // Test 1: Simple subtraction
        x = 2 << INT_SHIFT; // 2.0 in Q16.16 (0x00020000)
        y = 1 << INT_SHIFT; // 1.0 in Q16.16 (0x00010000)
        #10;
        // Expected: diff = 1.0 in Q16.16 (0x00010000), overflow = 0

        // Test 2: Checking for negative overflow
        x = 32'h80000000;    // Largest negative number in 32-bit signed (0x80000000)
        y = 1;               // Fractional value of 1/65536 in Q16.16 (positive very small fraction)
        #10;
        // Expected: overflow = 1 (because the difference is smaller than the largest negative number representable)

        $stop; // End the simulation
    end

endmodule

module tb_fip_32_mult();

    parameter INT_SHIFT = 16; // For Q16.16 fixed-point format

    reg signed [31:0] x, y;
    wire signed [31:0] prod;
    wire overflow;

    // Instantiate the multiplier module
    fip_32_mult mult_inst (
        .x(x),
        .y(y),
        .prod(prod),
        .overflow(overflow)
    );

    initial begin
        // Test 1: Simple multiplication without overflow
        x = 1 << INT_SHIFT; // 1.0 in Q16.16 (0x00010000 or 65536 as signed integer)
        y = 1 << INT_SHIFT; // 1.0 in Q16.16 (0x00010000 or 65536 as signed integer)
        #10;
        // Expected: prod = 1.0 in Q16.16 (0x00010000 or 65536 as signed integer), overflow = 0

        // Test 2: Multiplication that results in overflow
        x = 32'h40000000;    // Large positive value in Q16.16 (1073741824 as signed integer)
        y = 4 << INT_SHIFT;  // 4.0 in Q16.16 (0x00040000 or 262144 as signed integer)
        #10;
        // Expected: overflow = 1 (because it should result in a value that exceeds the maximum positive 32-bit integer)

        // Test 3: Multiplication with a negative value 
        x = 32'hC0000000;    // Large negative value in Q16.16 (-1073741824 as signed integer)
        y = -4 << INT_SHIFT; // -4.0 in Q16.16 (0xFFFC0000 or -262144 as signed integer)
        #10;
        // Expected: overflow = 1 (because it should result in a value that exceeds the maximum positive 32-bit integer)

        // Test 4: Edge case, multiplication by zero
        x = 1 << INT_SHIFT; // 1.0 in Q16.16 (0x00010000 or 65536 as signed integer)
        y = 0; // 0 in Q16.16
        #10;
        // Expected: prod = 0 in Q16.16, overflow = 0

        // Test 5: Fractional multiplication without overflow
        x = 32'h00008000; // 0.5 in Q16.16 (32768 as signed integer)
        y = 32'h00008000; // 0.5 in Q16.16 (32768 as signed integer)
        #10;
        // Expected: prod = 0.25 in Q16.16 (0x00004000 or 16384 as signed integer), overflow = 0

        // Test 6: Fractional multiplication with one negative operand
        x = 32'hFFFF8000; // -0.5 in Q16.16 (-32768 as signed integer)
        y = 32'h00008000; // 0.5 in Q16.16 (32768 as signed integer)
        #10;
        // Expected: prod = -0.25 in Q16.16 (0xFFFFC000 or -16384 as signed integer), overflow = 0

        // Test 7: Small fractional multiplication without overflow
        x = 32'h00000001; // Very small positive fraction in Q16.16 (1 as signed integer)
        y = 32'h00000001; // Very small positive fraction in Q16.16 (1 as signed integer)
        #10;
        // Expected: prod is a very small positive fraction in Q16.16 (0x00000000 or 0 as signed integer), overflow = 0

        $stop; 
    end

endmodule

module tb_fip_32_div();

    parameter INT_SHIFT = 16; // For Q16.16 fixed-point format

    reg signed [31:0] x, y;
    wire signed [31:0] prod;
    wire overflow;
    wire underflow;

    // Instantiate the division module
    fip_32_div div_inst (
        .dividend(x),
        .divisor(y),
        .quotient(prod),
        .overflow(overflow),
        .underflow(underflow)
    );

    initial begin
        // Test 1: Division of integer numbers without overflow
        x = 2 << INT_SHIFT; // 2.0 in Q16.16 (131072)    
        y = 2 << INT_SHIFT; // 2.0 in Q16.16 (131072)
        #10;
        // Expected: quotient = 1.0 in Q16.16 (65536) with no overflow

        // Test 2: Division by 0, underflow set
        x = 1 << INT_SHIFT; // 1.0 in Q16.16 (65536)
        y = 32'b0; // 0.0
        #10;
        // Expected: underflow set due to division by 0 

        // Test 3: Division of fractional numbers
        x = (0.5 * (2**INT_SHIFT)); // 0.5 in Q16.16 (32768)
        y = (0.25 * (2**INT_SHIFT)); // 0.25 in Q16.16 (16384)
        #10;
        // Expected: quotient = 2.0 in Q16.16 (131072) with no overflow

        // Test 4: Division leading to overflow
        x = 32'h7FFFFFFF; // Close to max positive value of Q16.16
        y = 1 << (INT_SHIFT - 2); // 0.25 in Q16.16 (16384)
        #10;
        // Expected: quotient larger than can be represented, overflow set

        // Test 5: Division of small numbers
        x = 2;  // 2/65536 in Q16.16 (2)
        y = 3;  // 3/65536 in Q16.16 (3)
        #10;
        // Expected: quotient = 2/3 in Q16.16 (43708) with no underflow/overflow
        // RESULT: 43690, which is an error of 0.0002746582. Negligible.

        // Test 6: Division with negative numbers
        x = -1 << INT_SHIFT; // -1.0 in Q16.16 (-65536)
        y = (0.5 * (2**INT_SHIFT)); // 0.5 in Q16.16 (32768)
        #10;
        // Expected: quotient = -2.0 in Q16.16 (-131072) with no overflow

        $stop;
    end
endmodule


module tb_fip_32_3b3_det();

    reg signed [31:0] i_array[2:0][2:0];
    wire signed [31:0] o_det;
    wire overflow;

    // Instantiate the 3x3 determinant module
    fip_32_3b3_det det_inst (
        .i_array(i_array),
        .o_det(o_det),
        .overflow(overflow)
    );

    initial begin
        // Test 1: Determinant of an identity matrix
        i_array[0] = '{32'h00010000, 32'b0, 32'b0}; // 1, 0, 0 in Q16.16
        i_array[1] = '{32'b0, 32'h00010000, 32'b0}; // 0, 1, 0 in Q16.16
        i_array[2] = '{32'b0, 32'b0, 32'h00010000}; // 0, 0, 1 in Q16.16
        #10;
        // Expected: o_det = 1 in Q16.16 (65536) with no overflow

        // Test 2: Determinant with random values
        i_array[0] = '{32'h00010000, 32'h00020000, 32'h00030000}; // 1, 2, 3 in Q16.16
        i_array[1] = '{32'h00040000, 32'h00050000, 32'h00060000}; // 4, 5, 6 in Q16.16
        i_array[2] = '{32'h00070000, 32'h00080000, 32'h00090000}; // 7, 8, 9 in Q16.16
        #10;
        // Expected: o_det = 0 with no overflow (since the matrix is singular)

        // Test 3: Determinant with some negative values
        i_array[0] = '{32'h00010000, 32'hFFFF0000, 32'h00030000}; // 1, -1, 3 in Q16.16
        i_array[1] = '{32'h00040000, 32'h00050000, 32'h00060000}; // 4, 5, 6 in Q16.16
        i_array[2] = '{32'h00070000, 32'h00080000, 32'h00090000}; // 7, 8, 9 in Q16.16
        #10;
        // Expected: o_det = -18 in Q16.16 (-1179648) with no overflow

        // Test 4: Testing overflow condition
        i_array[0] = '{32'h7FFF0000, 32'h7FFF0000, 32'h7FFF0000}; // Large values in Q16.16
        i_array[1] = '{32'h7FFF0000, 32'h7FFF0000, 32'h7FFF0000}; // Large values in Q16.16
        i_array[2] = '{32'h7FFF0000, 32'h7FFF0000, 32'h7FFF0000}; // Large values in Q16.16
        #10;
        // Expected: overflow should be detected
        
        $stop;
    end
endmodule

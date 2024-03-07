// basic fip operations, testbench
`timescale 1ns/1ns

`define TRUE 1
`define FALSE 0
`define FIP_MIN 32'sh80000000
`define FIP_MAX 32'sh7fffffff

module fip_32_add_sat_tb();
    logic signed [31:0] x, y, sum;

    fip_32_add_sat dut (
        .i_x(x),
        .i_y(y),
        .o_z(sum)
    );

    initial begin
        // overflow & underflow cut

        // Test 1: Simple addition
        x = 1 << 16; // 1.0 in Q16.16 (0x00010000)
        y = 1 << 16; // 1.0 in Q16.16 (0x00010000)
        #10;
        // Expected: no overflow, sum = 2.0 in Q16.16 (0x00020000)

        // Test 2: Addition with negative value
        x = -1 << 16; // -1.0 in Q16.16 (0xFFFF0000)
        y = -1;              // Fractional value of -1/65536 in Q16.16 (negative very small fraction)
        #10;
        // Expected: no overflow, sum is slightly less than -1.0 in Q16.16 (0xfffeffff)

        // Test 3: Checking for overflow
        x = `FIP_MAX;
        y = 1 << 16; // 1.0 in Q16.16 (0x00010000)
        #10;
        // Expected: overflow, sum cut to FIP_MAX

        // Test 4: Checking for underflow
        x = `FIP_MIN;
        y = -1 << 16; // -1.0 in Q16.16 (0xFFFF0000)
        #10;
        // Expected: underflow, sum cut to FIP_MIN

        $stop;
    end

endmodule: fip_32_add_sat_tb

module fip_32_mult_tb();
    parameter FRA_BITS = 16; // For Q16.16 fixed-point format
    logic signed [31:0] x, y, prod;

    fip_32_mult #(
        .FRA_BITS(FRA_BITS)
    ) dut (
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
        x = 0.5 * (1 << FRA_BITS); // 0.5 in Q16.16 (32768 as signed integer)
        y = 0.5 * (1 << FRA_BITS); // 0.5 in Q16.16 (32768 as signed integer)
        #10;
        // Expected: prod = 0.25 in Q16.16 (0x00004000 or 16384 as signed integer), overflow = 0

        // Test 4: Fractional multiplication with one negative operand
        x = -0.5 * (1 << FRA_BITS); // -0.5 in Q16.16 (-32768 as signed integer)
        y = 0.5 * (1 << FRA_BITS); // 0.5 in Q16.16 (32768 as signed integer)
        #10;
        // Expected: prod = -0.25 in Q16.16 (0xFFFFC000 or -16384 as signed integer), overflow = 0

        // Test 5: Small fractional multiplication without overflow
        x = 1; // Very small positive fraction in Q16.16 (1 as signed integer)
        y = 1; // Very small positive fraction in Q16.16 (1 as signed integer)
        #10;
        // Expected: prod is a very small positive fraction in Q16.16 (0x00000000 or 0 as signed integer), overflow = 0

        $stop;
    end

endmodule: fip_32_mult_tb

module fip_32_div_tb();
    parameter SAT = `TRUE; // For saturation against overflow/underflow
    parameter FRA_BITS = 16; // For Q16.16 fixed-point format
    logic signed [31:0] x, y, quotient;

    fip_32_div #(
        .SAT(SAT),
        .FRA_BITS(FRA_BITS)
    ) dut (
        .i_x(x),
        .i_y(y),
        .o_z(quotient)
    );

    initial begin
        // no overflow or underflow

        // Test 1: Division of integer numbers without overflow
        x = 2 << FRA_BITS; // 2.0 in Q16.16 (131072)    
        y = 2 << FRA_BITS; // 2.0 in Q16.16 (131072)
        #10;
        // Expected: quotient = 1.0 in Q16.16 (65536) with no overflow

        // Test 2: Division of fractional numbers
        x = 0.5 * (1 << FRA_BITS); // 0.5 in Q16.16 (32768)
        y = 0.25 * (1 << FRA_BITS); // 0.25 in Q16.16 (16384)
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
        y = 0.5 * (1 << FRA_BITS); // 0.5 in Q16.16 (32768)
        #10;
        // Expected: quotient = -2.0 in Q16.16 (-131072) with no overflow

        // overflow & underflow cut
        // enabled when SAT = `TRUE
        
        // Test 5: Division leading to overflow
        x = `FIP_MAX; // fip max value
        y = 0.25 * (1 << FRA_BITS); // 0.25 in Q16.16 (16384)
        #10;
        // Expected: overflow, quotient cut to FIP_MAX

        // Test 6: Division leading to underflow
        x = `FIP_MIN; // fip min value
        y = 0.25 * (1 << FRA_BITS); // 0.25 in Q16.16 (16384)
        #10;
        // Expected: underflow, quotient cut to FIP_MIN

        $stop;
    end

endmodule: fip_32_div_tb

module fip_32_3b3_det_tb();
    logic signed [0:2][0:2][31:0] i_array;
    logic signed [31:0] o_det;
    logic o_valid;
    logic clk, rstn, en;
    always #10 clk = ~clk;

    fip_32_3b3_det dut (
        .i_clk(clk),
        .i_rstn(rstn),
        .i_en(en),
        .i_array(i_array),
        .o_det(o_det),
        .o_valid(o_valid)
    );

    initial begin
        clk = 1'b1;
        rstn = 1'b0;
        en = 1'b0;
        repeat(3) @(posedge clk);
        rstn = 1'b1;
        en = 1'b1;

        // Test 1: Determinant of an identity matrix
        i_array[0][0] = 1 << 16;       // 1 in Q16.16 (65536)
        i_array[0][1] = 0;        // 0 (0)
        i_array[0][2] = 0;        // 0 (0)

        i_array[1][0] = 0;        // 0 (0)
        i_array[1][1] = 1 << 16;       // 1 in Q16.16 (65536)
        i_array[1][2] = 0;        // 0 (0)

        i_array[2][0] = 0;        // 0 (0)
        i_array[2][1] = 0;        // 0 (0)
        i_array[2][2] = 1 << 16;       // 1 in Q16.16 (65536)
        @(posedge clk);
        // Expected: o_det = 1 in Q16.16 (65536) with no overflow

        // Test 2: Enable off
        en = 'b0;
        @(posedge clk);
        // Expected: valid off in one pipeline stage
        en = 'b1;

        // Test 3: Determinant with random values
        i_array[0][0] = 1 << 16; // 1 in Q16.16 (65536)
        i_array[0][1] = 2 << 16; // 2 in Q16.16 (131072)
        i_array[0][2] = 3 << 16; // 3 in Q16.16 (196608)

        i_array[1][0] = 4 << 16; // 4 in Q16.16 (262144)
        i_array[1][1] = 5 << 16; // 5 in Q16.16 (327680)
        i_array[1][2] = 6 << 16; // 6 in Q16.16 (393216)

        i_array[2][0] = 7 << 16; // 7 in Q16.16 (458752)
        i_array[2][1] = 8 << 16; // 8 in Q16.16 (524288)
        i_array[2][2] = 9 << 16; // 9 in Q16.16 (589824)
        @(posedge clk);
        // Expected: o_det = 0 with no overflow (since the matrix is singular)

        // Test 4: Determinant with some negative values
        i_array[0][0] = 1 << 16; // 1 in Q16.16 (65536)
        i_array[0][1] = -1 << 16; // -1 in Q16.16 (-65536)
        i_array[0][2] = 3 << 16; // 3 in Q16.16 (196608)

        i_array[1][0] = 4 << 16; // 4 in Q16.16 (262144)
        i_array[1][1] = 5 << 16; // 5 in Q16.16 (327680)
        i_array[1][2] = 6 << 16; // 6 in Q16.16 (393216)

        i_array[2][0] = 7 << 16; // 7 in Q16.16 (458752)
        i_array[2][1] = 8 << 16; // 8 in Q16.16 (524288)
        i_array[2][2] = 9 << 16; // 9 in Q16.16 (589824)
        @(posedge clk);
        // Expected: o_det = -18 in Q16.16 (-1179648) with no overflow

        en = 'b0;
        repeat(3) @(posedge clk);
        
        $stop;
    end

endmodule: fip_32_3b3_det_tb

/* unused
module fip_32_vector_cross_tb();
    logic signed [0:1][0:2][31:0] i_array;
    logic signed [0:2][31:0] o_prod;

    fip_32_vector_cross dut (
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

    fip_32_vector_normal dut (
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
*/

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



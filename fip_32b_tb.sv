module tb_fip_32_adder();

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
        // Test 1
        x = 32'b0000000000000001_0000000000000000;
        y = 32'b0000000000000001_0000000000000000;
        #10; // delay
        // Expected: sum = 16'b10 << 16, overflow = 0

        // Test 2
        x = 32'h7FFFFFFF;
        y = 16'h0001 << 16;
        #10; // delay
        // Expected: overflow = 1

        // Test 3
        x = 16'hFFFF << 16; // Negative smallest value
        y = -1; // -1
        #10; // delay
        // Expected: sum = 16'hFFFE << 16, overflow = 0
        

        $stop; // End the simulation
    end

endmodule

module tb_fip_32_sub();

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
        // Test 1
        x = 16'h0002 << 16;
        y = 16'h0001 << 16;
        #10;
        // Expected: diff = 16'h0001 << 16, overflow = 0

        // Test 2
        x = 32'h80000000; // Negative largest value
        y = 1;
        #10;
        // Expected: overflow = 1
        

        $stop; // End the simulation
    end

endmodule


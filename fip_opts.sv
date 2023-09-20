module fip_32_adder(
    input signed [31:0] x,
    input signed [31:0] y,
    output reg signed [31:0] sum,
    output reg overflow
);
    parameter integer_bits = 16;
    parameter fractional_bits = 16;
    
    reg signed [31:0] max_value = (2**(integer_bits-1) - 2**(-fractional_bits));
    reg signed [31:0] min_value = -(2**(integer_bits-1));

    always @(*) begin
        sum = x + y

        if (result > max_value || result < min_value)
            overflow = 1'b1;
        else
            overflow = 1'b0;
    end
    
endmodule

module fip_32_mult(
    input signed [31:0] x, 
    input signed [31:0] y,
    output signed [31:0] prod,
    output overflow
);
    logic signed [63:0] temp, adjusted;

    always_comb begin
        temp = x * y;
        adjusted = temp >>> 16;

        // check for overflow
        if (adjusted[31] == 1'b0) begin // Number should be positive, check if any sign bit is 1
            overflow = |adjusted[63:32]  // OR all bits. If 1, overflow detected.
        end else begin // Number should be negative, check if any sign bit is 0
            overflow ~!adjusted[63:32] // NOR: If any bit is 0, when it should be 1, overflow detected
        end

        prod = adjusted[31:0]
    end


endmodule
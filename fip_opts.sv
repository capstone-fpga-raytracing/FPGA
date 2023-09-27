module fip_32_adder(
    input signed [31:0] x,
    input signed [31:0] y,
    output reg signed [31:0] sum,
    output reg overflow
);
    parameter integer_bits = 16;
    parameter fractional_bits = 16;
    
    parameter MAX_VALUE = (2**(integer_bits-1) - 1) << fractional_bits;
    parameter MIN_VALUE = -(2**(integer_bits-1)) << fractional_bits;

    always_comb begin
        overflow = 0 // Initialization

        sum = x + y;

        if (sum > MAX_VALUE || sum < MIN_VALUE)
            overflow = 1'b1;
        else
            overflow = 1'b0;
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
        overflow = 0 // Initialization

        diff = x - y;

        if (diff > MAX_VALUE || diff < MIN_VALUE)
            overflow = 1'b1;
        else
            overflow = 1'b0;
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
        overflow = 0 // Initialization

        temp = x * y;
        adjusted = temp >>> 16;

        // check for overflow
        if (adjusted[31] == 1'b0) begin // Number should be positive, check if any sign bit is 1
            overflow = |adjusted[63:32];  // OR all bits. If 1, overflow detected.
        end else begin // Number should be negative, check if any sign bit is 0
            overflow = ~|adjusted[63:32]; // NOR: If any bit is 0, when it should be 1, overflow detected
        end

        prod = adjusted[31:0];
    end

endmodule

module fip_32_div(
    input signed [31:0] dividend,
    input signed [31:0] divisor,
    output signed [31:0] quotient,
    output reg overflow,
    output reg underflow
);
    signed logic [47:0] temp_dividend;
    assign temp_dividend = dividend << 16;
    always_comb begin
        overflow = 0 // Initialization
        underflow = 0 // Initialization
        if(divisor == 32'b0) begin
            quotient = 32'b0;
            underflow = 1'b1; // Div by 0 error indicated by 1'b1 in underflow signal
        end else begin
            quotient = temp_dividend / divisor;
            // Add overflow/underflow detection 
        end
    end

endmodule
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
    output signed [31:0] prod
);
    logic signed [63:0] temp;

    always_comb begin
        temp = x * y;
        prod = temp >> 16;
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
    assign temp_dividend = divided << 16;
    always_comb begin
        if(divisor == 32'b0)
            quotient = 32'b0;
        else begin
            quotient = temp_dividend / divisor;
        end
    end

endmodule
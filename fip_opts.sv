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


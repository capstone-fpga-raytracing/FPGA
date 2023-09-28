`timescale 1ns/1ns

module tb();
    localparam W = 8;
    logic [W-1:0] dut_x, dut_y;
    logic [W*2-1:0] dut1_out;
    logic [W:0] dut2_out;

    mult DUT1 (.x(dut_x), .y(dut_y), .out(dut1_out));
    adder DUT2 (.x(dut_x), .y(dut_y), .sum(dut2_out));

// inputs
initial begin
    for (integer x = 0; x < W * W; x++) begin
        for (integer y = 0; y < W * W; y++) begin
            logic [W*2-1:0] realp;
            realp = x * y;

            dut_x = x[W-1:0];
            dut_y = y[W-1:0];
            #5; // wait

            //check
            if (dut1_out !== realp) begin
                $display("Mismatch! %0d * %0d should be %0d, got %0d instead", x, y, realp, dut1_out);
                $stop(); // $ for system functions
            end
        end
    end

$display(" multi csm Test passed!");

    for (integer x = 0; x < W * W; x++) begin
        for (integer y = 0; y < W * W; y++) begin
            logic[W:0] realsum;
            realsum = x + y;

            dut_x = x[W-1:0];
            dut_y = y[W-1:0];
            #5; // wait

            //check
            if (dut2_out !== realsum) begin // x !== z
                $display("Mismatch! %0d + %0d should be %0d, got %0d instead", x, y, realsum, dut2_out);
                $stop(); // $ for system functions
            end
        end
    end

$display(" carry save adder Test passed!");

$stop();
end

endmodule

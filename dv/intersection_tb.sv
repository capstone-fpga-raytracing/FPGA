module intersection_tb();

    localparam signed min_t = 0;
    logic signed [0:2][0:2][31:0] i_tri; // i_tri[0] for vertex 0
    logic signed [0:1][0:2][31:0] i_ray; // i_ray[0] for origin(E), i_ray[1] for direction(D)
    logic signed [31:0] o_t;
    logic o_result, o_valid;
    logic clk, rstn, en;
    always #10 clk = ~clk;

    intersection #(
        .min_t(min_t)
    ) dut (
        .i_clk(clk),
        .i_rstn(rstn),
        .i_en(en),
        .i_tri(i_tri),
        .i_ray(i_ray),
        .o_t(o_t),
        .o_result(o_result),
        .o_valid(o_valid)
    );

    int test_index;
    logic error_flag;
    task automatic test(); begin
        en = 'b1;
        test_index += 'd1;
        error_flag = 1'b0;
        $display("[%0d]Test %0d begin", $time(), test_index);
        @(posedge clk);
        en = 'b0;

        /*
        if (o_normal !== ref_normal) begin
            $display("ERROR (normal): expect %h %h %h, get %h %h %h", ref_normal[0], ref_normal[1], ref_normal[2]
                    , o_normal[0], o_normal[1], o_normal[2]);
            error_flag = 1'b1;
        end

        if (o_result !== ref_result) begin
            $display("ERROR (result): expect %d, get %d", o_result, ref_result);
            error_flag = 1'b1;
        end

        if (error_flag) begin
            $stop();
        end

        $display("Test %0d end\n", test_index);
        */

    end
    endtask


    initial begin
        clk = 1'b1;
        rstn = 1'b0;
        en = 1'b0;
        repeat(10) @(posedge clk);
        rstn = 1'b1;
        test_index = 'd0;
        $display("\n[%0d]intersection: test begin\n", $time());

        // example
        i_tri[0][0] = 1 << 16;
        i_tri[0][1] = 1 << 16;
        i_tri[0][2] = 1 << 16;

        i_tri[1][0] = 2 << 16;
        i_tri[1][1] = 3 << 16;
        i_tri[1][2] = 2 << 16;

        i_tri[2][0] = 1 << 16;
        i_tri[2][1] = 1 << 16;
        i_tri[2][2] = 3 << 16;

        i_ray[0][0] = 0 << 16;
        i_ray[0][1] = 1 << 16;
        i_ray[0][2] = 1 << 16;

        i_ray[1][0] = 3 << 16;
        i_ray[1][1] = 0.5 * (1 << 16);
        i_ray[1][2] = 1.5 * (1 << 16);

        test();
        // expects result = 1, t = 180224 (2.75)


        repeat(12) @(posedge clk);
        $display("[%0d]intersection: test end\n", $time());
        $stop();
    end
endmodule: intersection_tb

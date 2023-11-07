module intersection_tb();

    localparam signed min_t = 0; // TO DO: CHANGE
    logic signed [31:0] i_triangle[2:0][2:0];
    logic signed [31:0] i_ray[1:0][2:0]; // [1] for origin, [0] for direction
    //logic signed [31:0] o_normal[2:0];
    //logic signed [31:0] ref_normal[2:0];
    logic o_invalid, ref_invalid; // overflow, div by 0
    logic o_result, ref_result; // 1 for true
    
    intersection #(.min_t(min_t)) intersection_inst (
        .i_triangle(i_triangle),
        .i_ray(i_ray),
        //.o_normal(o_normal),
        .o_invalid(o_invalid),
        .o_result(o_result)
    );

    int test_index;
    logic error_flag;
    task automatic test(); begin
        #50;
        test_index += 'd1;
        error_flag = 1'b0;
        $display("Test %0d begin", test_index);
        /*
        if (o_normal !== ref_normal) begin
            $display("ERROR (normal): expect %h, get %h", ref_normal, o_normal);
            error_flag = 1'b1;
        end
        */

        if (o_invalid !== ref_invalid) begin
            $display("ERROR (invalid): expect %d, get %d", o_invalid, ref_invalid);
            error_flag = 1'b1;
        end

        if (ref_result && o_result !== ref_result) begin
            $display("ERROR (result): expect %d, get %d", o_result, ref_result);
            error_flag = 1'b1;
        end

        /*
        // debug
        if (debug) begin
            $display("Test %0d, bug found", test_index);
        end
        */

        if (error_flag) begin
            $stop();
        end
        $display("Test %0d end\n", test_index);

    end
    endtask


    initial begin
        test_index = 'd0;

        // TO DO: add test cases (with ref results)

        // example
        //i_triangle = ;
        //i_ray = ;
        //ref_normal = ;
        //ref_invalid = ;
        //ref_result = ;
        test();

    end
endmodule
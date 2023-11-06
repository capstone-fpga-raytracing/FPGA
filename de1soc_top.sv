module de1soc_top 
(
    // Clock pins
    input                     CLOCK_50,

    // Seven Segment Displays
    output      [6:0]         HEX0,
    output      [6:0]         HEX1,
    output      [6:0]         HEX2,
    output      [6:0]         HEX3,
    output      [6:0]         HEX4,
    output      [6:0]         HEX5,

    // Pushbuttons
    input       [3:0]         KEY,

    // LEDs
    output      [9:0]         LEDR,

    // Slider Switches
    input       [9:0]         SW,

    // VGA
    output      [7:0]         VGA_B,
    output                    VGA_BLANK_N,
    output                    VGA_CLK,
    output      [7:0]         VGA_G,
    output                    VGA_HS,
    output      [7:0]         VGA_R,
    output                    VGA_SYNC_N,
    output                    VGA_VS
);

//ray_traverse traverser();

wire [31:0] q_a, q_b;

logic CLOCK_SLOW;
	
rate_divider rd ( CLOCK_50, CLOCK_SLOW);
	
reg [16:0] rdaddress;
wire [31:0] q;
	
initial begin
	rdaddress = 17'b0;
end

// memory read test
always@(posedge CLOCK_SLOW) begin
	rdaddress <= rdaddress + 17'd1;
end

data scenerom(
	.clock(CLOCK_50),
	.address_a(rdaddress),
	.address_b(17'd0),
	.rden_a(1'b1),
	.rden_b(1'b1),
	.q_a(q_a),
	.q_b(q_b)
);

hex_decoder h1(.hex_digit(q_a[3:0]),.segments(HEX0));
hex_decoder h2(.hex_digit(q_a[7:4]),.segments(HEX1));
hex_decoder h3(.hex_digit(q_a[11:8]),.segments(HEX2));
hex_decoder h4(.hex_digit(q_a[15:12]),.segments(HEX3));
hex_decoder h5(.hex_digit(q_a[19:16]),.segments(HEX4));
hex_decoder h6(.hex_digit(q_a[23:20]),.segments(HEX5));


	//// Clock signal
	//wire clk = CLOCK_50;
	//
	//// KEYs are active low, invert them here
	//wire reset = ~KEY[0];
	//wire enter = ~KEY[1];
	//
	//// Number guess input
	//wire [7:0] guess = SW[7:0];
	//
	//// The actual game module
	//wire under;
	//wire over;
	//wire equal;
	//wire update_leds;
	//game game_inst
	//(
	//	.clk(clk),
	//	.reset(reset),
	//	.i_guess(guess),
	//	.i_enter(enter),
	//	.o_under(under),
	//	.o_over(over),
	//	.o_equal(equal),
	//	.o_update_leds(update_leds)
	//);
	//
	//// LED controllers
	//led_ctrl ledc_under(clk, reset, under, update_leds, LEDR[7]);
	//led_ctrl ledc_over(clk, reset, over, update_leds, LEDR[0]);
	//led_ctrl ledc_equal(clk, reset, equal, update_leds, LEDR[4]);
	//
	//// Hex Decoders
	//hex_decoder hexdec_guess0
	//(
	//	.hex_digit(guess[3:0]),
	//	.segments(HEX0)
	//);
	//
	//hex_decoder hexdec_guess1
	//(
	//	.hex_digit(guess[7:4]),
	//	.segments(HEX1)
	//);
	//
	//// Turn off the other HEXes
	
endmodule
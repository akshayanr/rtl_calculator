module lab7(SW, LEDG, KEY, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7, CLOCK_50);
	input CLOCK_50;
	input [17:0]SW;
	input [3:0]KEY;
	output [6:0]HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7;
	output [8:0]LEDG;
	
	//(Clock, Clear, Equals, Add, Subtract, Multiply, Divide, Number, Result, Overflow);
	/*parameter WIDTH = 11;							// Data bit width

// Inputs and Outputs
	reg Clock;
	reg Clear;											// C button
	reg Equals;											// = button: displays result so far; does not repeat previous operation
	reg Add;												// + button
	reg Subtract;										// - button
	reg Multiply;										// x button (multiply)
	reg Divide;											// Divide button
	reg [WIDTH-1:0] NumberSM; 					// Must be entered in sign-magnitude on SW[W-1:0]
	wire signed [WIDTH-1:0] Result;
	wire Overflow;
	wire CantDisplay;
	wire [4:0] State;

	//took out state.
	wire signed [WIDTH-1:0] NumberTC;
	SM2TC #(.width(WIDTH)) SM2TC1(NumberSM, NumberTC);*/
	
	wire signed [10:0] Result;
	wire Overflow;
	wire CantDisplay;
	wire [4:0] State;
	FourFuncCalc #(.W(11)) FFC(CLOCK_50, SW[17] & ~KEY[0],  SW[17] & ~KEY[3], ~SW[17] & ~KEY[3], ~SW[17] & ~KEY[2], ~SW[17] & ~KEY[1], ~SW[17] & ~KEY[0], SW[10:0], Result, Overflow);
	
	Binary_to_7SEG display(SW[10:0], 0, HEX7, HEX6, HEX5, HEX4);
	Binary_to_7SEG display_1(Result, 1, HEX3, HEX2, HEX1, HEX0);
	assign LEDG[8] = Overflow;
endmodule
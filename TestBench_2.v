`timescale 1ns/100ps
module TestBench_2();
	parameter WIDTH = 11;							// Data bit width

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
	SM2TC #(.width(WIDTH)) SM2TC1(NumberSM, NumberTC);
	FourFuncCalc #(.W(WIDTH)) FFC(Clock, Clear, Equals, Add, Subtract, Multiply, Divide, NumberSM, Result, Overflow);
	//(Clock, Clear, Equals, Add, Subtract, Multiply, Divide, Number, Result, Overflow);
	
// Define 10 ns Clock
	always #5 Clock = ~Clock;

	initial
	begin
		Clock = 0; Clear = 1;
		#20; Clear = 0;

	
//  1 + 2 + 3= 6
		#10; Equals = 1; NumberSM = 3; 
		#10; Equals = 0;

		#20; Multiply = 1;
		#20; Multiply = 0;
		#20; Equals = 1; NumberSM = 0; 
		#20; Equals = 0;
		/*Clear = 1;
		#20; Clear = 0;
		#10; Equals = 1; NumberSM = 1; 
		#10; Equals = 0;

		#20; Add = 1;
		#20; Add = 0;
		#20; Equals = 1; NumberSM = 2; 
		#20; Equals = 0;
		
		#20; Add = 1;
		#20; Add = 0;
		#20; Equals = 1; NumberSM = 2; 
		#20; Equals = 0;*/

		end

endmodule

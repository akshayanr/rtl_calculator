// ModelSim allows the use of "generate".
// This module defines a parameterized W-bit RCA adder/dubtsctor
/*module AddSub
	#(parameter W = 11)			// Default width
	(A, B, c0, S, ovf);
	input [W-1:0] A, B;			// W-bit unsigned inputs
	input c0;								// Carry-in
	output [W-1:0] S;				// W-bit unsigned output
	output ovf;							// Overflow signal

	wire [W:0] c;						// Carry signals
	assign c[0] = c0;

// Instantiate and "chain" W full adders 
	genvar i;
		generate
			for (i = 0; i < W; i = i + 1) begin: inst_loop
				FullAdder FA(A[i], B[i] ^ c[0], c[i], S[i], c[i+1]);
			end
		endgenerate

// Overflow
		assign ovf = c[W-1] ^ c[W];
endmodule*/

// Four-Function Calculator TestBench
`timescale 1ns/100ps
module TestBench();
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
		#10; Equals = 1; NumberSM = 1; 
		#10; Equals = 0;

		#20; Multiply = 1;
		#20; Multiply = 0;
		#20; Equals = 1; NumberSM = 2; 
		#20; Equals = 0;
		
		#500; Multiply = 1;
		#30; Multiply = 0;
		#30; Equals = 1; 
		#30; NumberSM = 3; 
		#30; Equals = 0;
		/*#20; Multiply = 1;
		#20; Multiply = 0;
		#20; Equals = 1; NumberSM = 3; 
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


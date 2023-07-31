// Conversion between signed-magnitude and two's complement

module SM2TC
	#(parameter width = 11)
	(SM, TC);
	input [width-1:0] SM;
	output [width-1:0] TC;

	wire [width-2:0] tmp;                 // Magnitude
	assign tmp = ~(SM[width-2:0]) + 'b1;  // Flip bits and add 1
 	assign TC = SM[width-1] ?             // Negative
                (tmp == 0 ?             // Negative zero
                  'd0 :                 // Convert to "positive" zero          
                  {1'b1, tmp}):         // Prepend negative sign
                SM;                     // Positive
endmodule

module TC2SM
	#(parameter width = 11)
	(TC, SM, Overflow);
	input [width-1:0] TC;
	output [width-1:0] SM;
  output Overflow;

	wire [width-1:0] Magnitude;
	assign Magnitude = TC[width-1] ?                // Negative
                       ~(TC[width-1:0]) + 1'b1 :  // Flip bits and add 1
                       TC;                        // Positive
	assign SM = {TC[width-1], Magnitude[width-2:0]};// Prepend sign
  assign Overflow = TC[width-1] & ~TC[width-2:0]; // Most negative TC numbe
                                                  // Alternatively, Overflow = Magnitude[width-1]
endmodule
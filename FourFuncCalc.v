// EECS 270
// Lab 7:Four-Function Calculator Template
module FourFuncCalc
	#(parameter W = 11)			// Default bit width
	(Clock, Clear, Equals, Add, Subtract, Multiply, Divide, Number, Result, Overflow);
	localparam WW = 2 * W;		// Double width for Booth multiplier
	localparam BoothIter = $clog2(W);	// Width of Booth Counter
	input Clock;
	input Clear;				// C button
	input Equals;				// = button: displays result so far; does not repeat previous operation
	input Add;					// + button
	input Subtract;				// - button
	input Multiply;				// x button (multiply)
	input Divide;				// / button (division quotient)
	input [W-1:0] Number; 			// Must be entered in sign-magnitude on SW[W-1:0]
	output signed [W-1:0] Result;		// Calculation result in two's complement
	output Overflow;			// Indicates result can't be represented in W bits

  
//****************************************************************************************************
// Datapath Components
//****************************************************************************************************


//----------------------------------------------------------------------------------------------------
// Registers
// For each register, declare it along with the controller commands that
// are used to update its state following the example for register A
//----------------------------------------------------------------------------------------------------
	
	reg signed [W-1:0] A;			// Accumulator
	wire CLR_A, LD_A, LD_N;			// CLR_A: A <= 0; LD_A: A <= Q
	wire signed [W-1:0] R;
	reg signed [W-1:0] N_TC;
	reg signed [WW + 1:0] PM;
	reg [W-1: 0] MCounter;
	reg signed [W-1:0] N_SM;
	wire mult_ovf;
	
	//multiplication wires.
	wire M_LD, P_LD, PM_ASR, CTR_DN, reset_counter;
	wire signed [W:0] ZERO; 					// (W+1)-bit 0 since `(W+1)'d0 does not work
	assign ZERO = 'd0;
	
	reg signed [W - 1:0] D;
	reg [W-1: 0] DCounter;
	
	//some division wires.
	wire reset_div, CTR_Div, D_LD;
	
  
//----------------------------------------------------------------------------------------------------
// Number Converters
// Instantiate the three number converters following the example of SM2TC1
//----------------------------------------------------------------------------------------------------

	wire signed [W-1:0] NumberTC;		// Two's complement of Number
	SM2TC #(.width(W)) SM2TC1(Number, NumberTC);

	wire signed [W-1:0] D_SM_signed;
	TC2SM #(.width(W)) TC2SM1(A, D_SM_signed);
	
	wire signed [W-1:0] D_SM;
	assign D_SM = {1'd0, D_SM_signed[W-2:0]};
	
	wire signed [W-1:0] Q_TC;		// Two's complement of Number
	SM2TC #(.width(W)) SM2TC2(DCounter, Q_TC);

//----------------------------------------------------------------------------------------------------
// MUXes
// Use conditional assignments to create the various MUXes
// following the example for MUX Y1
//----------------------------------------------------------------------------------------------------
	
	//commented out.
	wire SEL_D;
	wire signed [W-1:0] Y2;
	assign Y2 = SEL_D ? N_SM : N_TC;
	
	wire signed [W-1:0] Y3;
	assign Y3 = SEL_D ? D : A;
	
	wire SEL_P;
	wire signed [W-1:0] Y1; 									
	assign Y1 = SEL_P? PM[WW + 1:W+1] : Y3;	// 1: Y1 = P; 0: Y1 = Y3*/
	
	
	//now wire sel_M
	wire SEL_M;
	wire signed [W-1:0] Y4; 	
	assign Y4 = SEL_M ? PM[W:1]: R;						
	
	wire SEL_A;
	wire signed [W-1:0]Y7;
	//if SEL_N, get NumberTC, or else just get the sum.
	//R is the wire below, it hasn't been defined. 
	//R is the result of the adder.
	assign Y7 = SEL_A ? D_SM : R;	
	
	wire SEL_Q;
	wire signed [W-1:0] Y5; 
	assign Y5 = SEL_Q ? Q_TC : Y4;
	
	wire SEL_N;
	wire signed [W-1:0]Y6;
	//if SEL_N, get NumberTC, or else just get the sum.
	//R is the wire below, it hasn't been defined. 
	//R is the result of the adder.
	assign Y6 = SEL_N ? Y2 : Y5;
  //(Clock, Reset, Start, M, Q, P);
//----------------------------------------------------------------------------------------------------
// Adder/Subtractor
//start when counter is Zero.
	wire Start;
	//when clear, or when finished. 
	wire Reset;
	//BoothMul #(.W(W)) boothmul(Clock, Reset, Start, A, N_TC, P);
	//A is M and N_TC is Q.
//----------------------------------------------------------------------------------------------------
	//addSub module:
	wire c0;				// 0: Add, 1: Subtract
	wire ovf;				// Overflow
	AddSub #(.W(W)) AddSub1(Y1, Y2, c0, R, ovf);
	wire PSgn = R[W-1] ^ ovf;		// Corrected P Sign on Adder/Subtractor overflow
	//check 12.
	assign mult_ovf = (PM[WW + 1:W+1] != 12'b000000000000 && PM[WW +1: W + 1] != 12'b111111111111);


//****************************************************************************************************
/* Datapath Controller
   Suggested Naming Convention for Controller States:
     All names start with X (since the tradtional Q connotes quotient in this project)
     XAdd, XSub, XMul, and XDiv label the start of these operations
     XA: Prefix for addition states (that follow XAdd)
     XS: Prefix for subtraction states (that follow XSub)
     XM: Prefix for multiplication states (that follow XMul)
     XD: Prefix for division states (that follow XDiv)
*/
//****************************************************************************************************


//----------------------------------------------------------------------------------------------------
// Controller State and State Labels
// Replace ? with the size of the state registers X and X_Next after
// you know how many controller states are needed.
// Use localparam declarations to assign labels to numeric states.
// Here are a few "common" states to get you started.
//----------------------------------------------------------------------------------------------------

	reg [4:0] X, X_Next;
	
	//initial state, go back to initial state when clear.
	localparam XInit	= 5'd0;	// Power-on state (A == 0)
	
	//if number is pressed before the + operation.
	localparam XLoadA_inital = 5'd1;
	
	//result is loaded after the addition.
	localparam XLoadA = 5'd2;
	
	//where operation is performed. 
	localparam Xadd = 5'd3;
	
	//state for handling overflow.
	localparam Xhandle_overflow = 5'd4;
	
	
	//get number to add.
	localparam Xget_number = 5'd5;
	
	//buffer state
	localparam Xbuffer = 5'd6;
	
	localparam Xsub = 5'd7;
	
	//get number to add.
	localparam Xget_number_sub = 5'd8;
	
	localparam XLoadA_sub = 5'd9;
	
	localparam Xbuffer_sub = 5'd10;
	
	localparam Xget_number_mult = 5'd11;
	
	localparam XLoadA_mult = 5'd12;
	
	localparam Xbuffer_mult = 5'd13;
	//init
	localparam Xmult = 5'd14;
	localparam Xmult_load = 5'd15; 
	localparam Xmult_check = 5'd16; 
	localparam Xmult_add	= 5'd17;
	localparam Xmult_sub	= 5'd18;
	localparam Xmult_next = 5'd19;		
	localparam Xmult_more = 5'd20;
	localparam Xget_number_div = 5'd21;
	localparam Xdiv = 5'd22;
	localparam Xdiv_load = 5'd23;
	localparam Xdiv_sub = 5'd24;
	localparam Xdiv_check = 5'd25;
	localparam XLoadA_div = 5'd26;
	localparam Xbuffer_div = 5'd27;
	localparam Xincrease_DCounter = 5'd28;
	localparam Xbuffer_initial = 5'd29;
	
	
	

//----------------------------------------------------------------------------------------------------
// Controller State Transitions
// This is the part of the project that you need to figure out.
// It's best to use ModelSim to simulate and debug the design as it evolves.
// Check the hints in the lab write-up about good practices for using
// ModelSim to make this "chore" manageable.
// The transitions from XInit are given to get you started.
//----------------------------------------------------------------------------------------------------

	always @*
	case (X)
		XInit:
			if (Equals)
				X_Next <= XLoadA_inital;
			else if (Add)
				X_Next <= Xget_number;
			else if (Subtract)
				X_Next <= Xget_number_sub;
			else if(Multiply)
				X_Next <= Xget_number_mult;
			else if(Divide)
				X_Next <= Xget_number_div;
			else
				X_Next <= XInit;
		XLoadA_inital:
			X_Next <= Xbuffer_initial;
		Xbuffer_initial:
			if (Add)
				X_Next <= Xget_number;
			else if (Subtract)
				X_Next <= Xget_number_sub;
			else if(Multiply)
				X_Next <= Xget_number_mult;
				else if(Divide)
				X_Next <= Xget_number_div;
			else if (Clear)
				X_Next <= XInit;
			else
				X_Next <= Xbuffer_initial;
		Xget_number:
			if (Equals)
				X_Next <= Xadd;
			else if (Clear)
				X_Next <= XInit;
			else
				X_Next <= Xget_number;
		Xget_number_sub:
			if (Equals)
				X_Next <= Xsub;
			else if (Clear)
				X_Next <= XInit;
			else
				X_Next <= Xget_number_sub;
		Xget_number_mult: //loading q.
			if(Equals)
				X_Next <= Xmult;
			else if (Clear)
				X_Next <= XInit;
			else
				X_Next <= Xget_number_mult;
		Xget_number_div:
			if(Equals)
				X_Next <= Xdiv;
			else if (Clear)
				X_Next <= XInit;
			else
				X_Next <= Xget_number_div;
		Xadd:
			if(ovf)
				X_Next <= Xhandle_overflow;
			else if(Clear)
				X_Next <= XInit;
			else
				X_Next <= XLoadA;
		Xsub:
			if(ovf)
				X_Next <= Xhandle_overflow;
			else if(Clear)
				X_Next <= XInit;
			else
				X_Next <= XLoadA_sub;
		Xhandle_overflow:
			if(Clear)
				X_Next <= XInit;
			else
				X_Next <= Xhandle_overflow;
		XLoadA:
			if(Clear)
				X_Next <= XInit;
			else if(Add)
				X_Next <= Xget_number;
			else if(Subtract)
				X_Next <= Xget_number_sub;
			else if(Multiply)
				X_Next <= Xget_number_mult;
			else if(Divide)
				X_Next <= Xget_number_div;
			else
				X_Next <= Xbuffer;
		XLoadA_sub:
			if(Clear)
				X_Next <= XInit;
			else if(Add)
				X_Next <= Xget_number;
			else if(Subtract)
				X_Next <= Xget_number_sub;
			else if(Multiply)
				X_Next <= Xget_number_mult;
			else if(Divide)
				X_Next <= Xget_number_div;
			else
				X_Next <= Xbuffer_sub;
		XLoadA_mult:
			if(Clear)
				X_Next <= XInit;
			else
				X_Next <= Xbuffer_mult;
		Xbuffer:
			if(Clear)
				X_Next <= XInit;
			else if(Add)
				X_Next <= Xget_number;
			else if(Subtract)
				X_Next <= Xget_number_sub;
			else if(Multiply)
				X_Next <= Xget_number_mult;
			else if(Divide)
				X_Next <= Xget_number_div;
			else
				X_Next <= Xbuffer;
		Xbuffer_sub:
			if(Clear)
				X_Next <= XInit;
			else if(Add)
				X_Next <= Xget_number;
			else if(Subtract)
				X_Next <= Xget_number_sub;
			else if(Multiply)
				X_Next <= Xget_number_mult;
			else if(Divide)
				X_Next <= Xget_number_div;
			else
				X_Next <= Xbuffer_sub;
		Xbuffer_mult:
			if(Clear)
				X_Next <= XInit;
			else if(Add)
				X_Next <= Xget_number;
			else if(Subtract)
				X_Next <= Xget_number_sub;
			else if(Multiply)
				X_Next <= Xget_number_mult;
			else if(Divide)
				X_Next <= Xget_number_div;
			else
				X_Next <= Xbuffer_mult;
		Xmult:
			if(Clear)
				X_Next <= XInit;
			else
				X_Next <= Xmult_load;
		Xmult_load:	
			if(Clear)
				X_Next <= XInit;
			else
				X_Next <= Xmult_check;
			
		Xmult_check:
			if (~PM[1] & PM[0])
					X_Next <= Xmult_add;
			else if (PM[1] & ~PM[0])
					X_Next <= Xmult_sub;
			else
					X_Next <= Xmult_next;

		Xmult_add: X_Next <= Xmult_next;

		Xmult_sub: X_Next <= Xmult_next;

		Xmult_next: X_Next <= Xmult_more;

		Xmult_more:
			if (MCounter == 'd0 & ~mult_ovf)
					X_Next <= XLoadA_mult;
			else if (MCounter == 'd0 & mult_ovf)
					X_Next <= Xhandle_overflow;
			else
					X_Next <= Xmult_check;
		Xdiv:
			if(Clear)
				X_Next <= XInit;
			else
				X_Next <= Xdiv_load;
		Xdiv_load:
			if(Clear)
				X_Next <= XInit;
			else
				X_Next <= Xdiv_sub;
		Xdiv_sub: X_Next <= Xdiv_check;
		
		Xdiv_check:
			if(D < 0)
				X_Next <= XLoadA_div;
			else 
				X_Next <= Xincrease_DCounter;
		Xincrease_DCounter:
			X_Next <= Xdiv_sub;
		XLoadA_div:
			if(Clear)
				X_Next <= XInit;
			else
				X_Next <= Xbuffer_div;
		Xbuffer_div:
			if(Clear)
				X_Next <= XInit;
			else if(Add)
				X_Next <= Xget_number;
			else if(Subtract)
				X_Next <= Xget_number_sub;
			else if(Multiply)
				X_Next <= Xget_number_mult;
			else
				X_Next <= Xbuffer_div;
		
	endcase
  
  
//----------------------------------------------------------------------------------------------------
// Initial state on power-on
// Here's a freebie!
//----------------------------------------------------------------------------------------------------

	initial begin
		X <= XInit;
		A <= 'd0;
		N_TC <= 'd0;
		N_SM <= 'd0;
		MCounter <= W;		//BoothIter'dW;
		PM <= 'd0;		//WW+1'd0;
		D <= 'd0;
		DCounter <= 'd0;
	end


//----------------------------------------------------------------------------------------------------
// Controller Commands to Datapath
// No freebies here!
// Using assign statements, you need to figure when the various controller
//	commands are asserted in order to properly implement the datapath
// operations.
//----------------------------------------------------------------------------------------------------


//----------------------------------------------------------------------------------------------------  
// Controller State Update
//----------------------------------------------------------------------------------------------------

	always @(posedge Clock)
		if (Clear)
			X <= XInit;
		else
			X <= X_Next;

      
//----------------------------------------------------------------------------------------------------
// Datapath State Update
// This part too is your responsibility to figure out.
// But there is a hint to get you started.
//----------------------------------------------------------------------------------------------------

	always @(posedge Clock)
	begin
		N_TC <= LD_N ? NumberTC : N_TC;
		N_SM <= LD_N ? {1'd0, Number[W-2:0]} : N_SM;
		//N_SM <= LD_N ? Number : N_SM;
		A <= CLR_A ? 0 : (LD_A ? Y6 : A);
		PM <= reset_counter ? 'd0 : (M_LD? $signed({ZERO, A, 1'b0}) : (P_LD ? $signed({PSgn, R, PM[W:0]}) : (PM_ASR ? PM >>> 1 : PM)));
		MCounter <= reset_counter ? W : (CTR_DN ? MCounter - 1 : MCounter);
		
		D <= reset_div ? 'd0 : (D_LD ? Y7: D);
		DCounter <= reset_div ? 'd0 : (CTR_Div ? DCounter + 1 : DCounter);
		
	end

 
//---------------------------------------------------------------------------------------------------- 
// Calculator Outputs
// The two outputs are Result and Overflow, get it?
//----------------------------------------------------------------------------------------------------
	//combinational so don't need always.
	assign SEL_P = (X == Xmult || X == Xmult_load || X == Xmult_check || X == Xmult_add	|| X == Xmult_sub || X == Xmult_next || X == Xmult_more || X == XLoadA_mult);
	//loadin into a for next.
	assign SEL_M = (X == XLoadA_mult);
	assign SEL_D = (X == Xdiv || X == Xdiv_load || X == Xdiv_sub || X == Xdiv_check || X == XLoadA_div || X == Xincrease_DCounter);
	assign SEL_A = (X == Xdiv_load);
	assign SEL_Q = (X == XLoadA_div);
	assign SEL_N = (X == XLoadA_inital);
	assign LD_N = (X == XInit || X == Xget_number || X == Xget_number_sub || X == Xget_number_mult || X == Xget_number_div);
	assign CLR_A = (X == XInit);
	assign LD_A = (X == XLoadA || X == XLoadA_inital || X == XLoadA_sub || X == XLoadA_mult || X == XLoadA_div);
	assign Result = A;
	assign Overflow = (X == Xhandle_overflow);
	//c0 is 0 initially for addition, so if I actuallay wanna subtract. 
	assign c0 = (X == Xsub || X == XLoadA_sub || X == Xsub || X == Xget_number_sub || X == Xbuffer_sub || X == Xmult_sub || X == Xdiv_sub);
	assign M_LD	= (X == Xmult_load);
	assign P_LD	= (X == Xmult_add) | (X == Xmult_sub);
	assign PM_ASR 	= (X == Xmult_next);
	assign CTR_DN 	= (X == Xmult_next);
	//reset whenever x_mult.
	assign reset_counter = (X == Xbuffer_mult);
	assign reset_div = (X == Xbuffer_div);
	assign CTR_Div = (X == Xincrease_DCounter);
	assign D_LD = (X == Xdiv_load || X == Xdiv_sub);
endmodule

//addSub module. 
module AddSub
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
				FA FullAdder(A[i], B[i] ^ c[0], c[i], S[i], c[i+1]);
			end
		endgenerate

// Overflow
		assign ovf = c[W-1] ^ c[W];
endmodule



//FA FullAdder(A[i], B[i] ^ c[0], c[i], S[i], c[i+1]);
module FA(a, b, cin, s, cout);
	input a;
	input b;
	input cin;
	output cout;
	output s;
	
	
	// TODO: Set X, Y, and Co appropriately
	//what's xxorleft would have to be 0.
	assign s  = (a ^ b) ^ cin;
	
	//if not 10 or 00, x has to be 0 because of absolute avlue operation.
	assign cout = ((a ^ b) & cin) | (a & b);

endmodule
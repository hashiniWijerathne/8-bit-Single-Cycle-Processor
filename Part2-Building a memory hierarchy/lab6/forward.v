// group 22-part1
// Forward module

`timescale 1ns/100ps

module FORWARD(DATA2,RESULT_1); //module for FORWARD functional unit - loadi & mov instructions supported
	

	//input and output ports declaration - 8 bits used for each one
	input [7:0] DATA2;
	output [7:0] RESULT_1;

	assign #1 RESULT_1 = DATA2; //operation happens after 1 time unit delay

endmodule

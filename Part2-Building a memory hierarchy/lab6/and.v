// group 22-part1
// And module

`timescale 1ns/100ps

module AND(DATA1,DATA2,RESULT_3); //module for AND functional unit - and instruction supported

	//input and output ports declaration - 8 bits used for each one
	input [7:0] DATA1,DATA2;
	output [7:0] RESULT_3;	

	assign #1 RESULT_3 = DATA1 & DATA2;

endmodule

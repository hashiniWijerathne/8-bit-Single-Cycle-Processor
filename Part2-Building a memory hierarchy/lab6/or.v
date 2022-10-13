// group 22-part1
// Or module

`timescale 1ns/100ps

module OR(DATA1,DATA2,RESULT_4); //module for OR functional unit - or instruction supported

	//input and output ports declaration - 8 bits used for each one
	input [7:0] DATA1,DATA2;
	output [7:0] RESULT_4;	

	assign #1 RESULT_4 = DATA1 | DATA2; //operation happens after 1 time unit delay

endmodule

// group 22-part1
// Add module

module ADD(DATA1,DATA2,RESULT_2); //module for ADD functional unit - add & sub instructions supported
	
	//input and output ports declaration - 8 bits used for each one
	input [7:0] DATA1,DATA2;
	output [7:0] RESULT_2;

	assign #2 RESULT_2 = DATA1 + DATA2; //function happens after 2 units time delay

endmodule

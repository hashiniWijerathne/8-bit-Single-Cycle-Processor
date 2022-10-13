// group 22
// get the addition of jump branch address with PC value 

`timescale 1ns/100ps

module j_b_adder(out,pc,offset,INSTRUCTION);

	input [31:0] pc,offset,INSTRUCTION;
	output reg[31:0] out;

	always @(INSTRUCTION)
	begin
		#2
		out=pc+offset;
	end
endmodule

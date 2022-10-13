// group 22
// ALU module

module alu(DATA1,DATA2,RESULT,SELECT,ZERO); //alu module
	
	//input and output ports declaration
	input [7:0] DATA1,DATA2; //data
	input [2:0] SELECT; //selection which is used to select the required function inside the ALU out of the 							available four functions
	output [7:0] RESULT; //result
	output ZERO;

	//RESULT assigned as reg data type since some value will be assigned to RESULT
	reg [7:0] RESULT;
	//use 4 wires to get the output of available four functions
	wire [7:0] result_fwd, result_add, result_and, result_or; 

	//all modules(functional units) instantiated
	FORWARD fwd(DATA2,result_fwd);   //instance created from FORWARD module
	ADD add(DATA1,DATA2,result_add); //instance created from ADD module
	AND and0(DATA1,DATA2,result_and);//instance created from AND module
	OR or0(DATA1,DATA2,result_or);  //instance created from OR module

	//below always block acts as a mux to select between outputs of the functional units
	always @(DATA1,DATA2,SELECT,result_fwd,result_add,result_and,result_or) begin //always block triggered when either DATA1 or DATA2 changes

		case(SELECT) //case structure to handle different SELECT signals
		
		//for 000 select bits output of FORWARD functional unit assigned as RESULT
		3'b000 : RESULT = result_fwd;
	
		//for 001 select bits output of ADD functional unit assigned as RESULT
		3'b001 : RESULT = result_add;
		
		//for 010 select bits output of AND functional unit assigned as RESULT
		3'b010 : RESULT = result_and;
		
		//for 011 select bits output of OR functional unit assigned as RESULT
		3'b011 : RESULT = result_or;
		
		default: RESULT= 8'bz;
		
		endcase

	end
	//generating ZERO signal /if RESULT=8'b0 ZERO = 1
	assign ZERO=~(RESULT[0]|RESULT[1]|RESULT[2]|RESULT[3]|RESULT[4]|RESULT[5]|RESULT[6]|RESULT[7]);

endmodule

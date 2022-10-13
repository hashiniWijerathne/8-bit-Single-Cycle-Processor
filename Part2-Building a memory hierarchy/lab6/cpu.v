`include "alu.v"
`include "forward.v"
`include "add.v"
`include "and.v"
`include "or.v"
`include "regfile.v"
`include "muxto8.v"
`include "muxto32.v"
`include "shiftleft.v"
`include "extend.v"
`include "j_b_adder.v"
`include "data_memory.v"
`include "cache_memory.v"
`include "instruction_memory.v"
`include "cache_instruction.v"
`timescale 1ns/100ps

module cpu(PC,READ,WRITE,ADDRESS,WRITEDATA, INSTRUCTION, CLK, RESET,READDATA,BUSYWAIT,BUSYWAIT_INSTR);

	//input ports declaration
	input [31:0] INSTRUCTION;
	input CLK,RESET;

	//output port declaration	
	output reg [31:0] PC;

	//OPCODE - for each instruction
	//ALUOP - for each functional unit in ALU
	//READREG1,READREG2-to read 2 inputs from the register
	//WRITEREG- to write the output
	reg [2:0] ALUOP,READREG1,READREG2,WRITEREG;
	reg [3:0] OPCODE;

	reg [31:0] PC0; //PC0 is to hold the updated value of PC until the next positive edges

	//SELECT1-to select whether to take 2S complement or a REGOUT2 directly
	//SELECT2-to select whether to take IMMEDIATE value or REGOUT2(this can be REGOUT2 or 2s complement of REGOUT2)
	//SELECT3-to select whether to take OFFSET and BRANCH address or not
	//SELECT4-selects between ALURESULT & READDATA
	//READ - to read from data memory
	//WRITE - to write to data memory
	reg WRITEENABLE,SELECT1,SELECT2,SELECT3,SELECT4;

	reg [7:0] IMMEDIATE,OFFSET;

	//wire connections
	//complement- negative of REGOUT2
	//MUX1OUT = output of mux1
	//OPERAND2 = output of mux2
	wire [7:0] ALURESULT,COMPLEMENT,REGOUT2,REGOUT1,MUX1OUT,OPERAND2;
	//PC2-output of mux3
	//PC3-output of mux4
	wire [31:0] PC2,PC3;

	wire ZERO; 		//to check whether the ALURESULT is zero or not
	wire [9:0] shiftout;	//to get the output when the OFFSET shifting by 2(10 bits)
	//extendout-to get the output when OFFSET in 10 bits are extend upto 32 bits
	//addout-to get the output of branch/jump adder
	wire [31:0] extendout,addout;

	//to get busywait output from data memory
	input BUSYWAIT, BUSYWAIT_INSTR;

	//READDATA -to get data read from data memory
	//MUXOUT0 - to get output from muxto08 (selects between ALURESULT & READDATA)
	wire [7:0] MUXOUT0;
	input [7:0] READDATA;

	//ADDRESS - given as ALURESULT
	//WRITEDATA - given as REGOUT1
	output reg [7:0] ADDRESS, WRITEDATA;
	output reg READ,WRITE;
	wire NEWWRITEENABLE;
	
	//PC adder
	always @(PC)
	begin
		#1 PC0 = PC + 4;
	end

	//PC updater
	always @(posedge CLK)
	begin
		if(RESET) begin
			PC= #1 32'd0;
			PC0= #1 32'd0;
		end
		//new PC value is assigned only if BUSYWAIT is low
		
		else if(!BUSYWAIT && !BUSYWAIT_INSTR) #1 PC= PC3;
	end

	always @(BUSYWAIT) 
	begin
		//once busywait is low read & write signals assigned to 0
		if(!BUSYWAIT) begin
			READ = 1'b0;
			WRITE = 1'b0;
		end

	end

	

	//INSTRUCTION memory reading and get OFFSET,IMMEDIATE,READREG1,READREG2,WRITEREG addresses
	always @(INSTRUCTION)
	begin
		IMMEDIATE=INSTRUCTION[7:0];
		OFFSET=INSTRUCTION[23:16];
		READREG2=INSTRUCTION[2:0];
		READREG1=INSTRUCTION[10:8];
		WRITEREG=INSTRUCTION[18:16];
	end


	//checking OPCODE and generating Control signals
	always @(INSTRUCTION)
	begin
		
		case(INSTRUCTION [31:24])
		8'd0:begin
			OPCODE=4'd0;       //for add instruction - 0
			#1		   //one unit delay for generating control signals
			SELECT1=1'b0;
			SELECT2=1'b0;
			SELECT3=1'b0;
			ALUOP=3'd1;	   // add instruction - ADD functional unit
			WRITEENABLE=1'b1;
			READ=1'b0;
			WRITE=1'b0;
			SELECT4=1'b0;
		end
		8'd1:begin
			OPCODE=4'd1;	   //for sub instruction - 1
			#1		   //one unit delay for generating control signals
			SELECT1=1'b1;	   //to get 2s complement of regout2
			SELECT2=1'b0;
			SELECT3=1'b0;
			ALUOP=3'd1;	   // sub instruction - ADD functional unit
			WRITEENABLE=1'b1;
			READ=1'b0;
			WRITE=1'b0;
			SELECT4=1'b0;
			
		end
		8'd2:begin
			OPCODE=4'd2;  	   //for and instruction - 2
			#1		   //one unit delay for generating control signals
			SELECT1=1'b0;
			SELECT2=1'b0;
			SELECT3=1'b0;
			ALUOP=3'd2;	   // and instruction - AND functional unit
			WRITEENABLE=1'b1;
			READ=1'b0;
			WRITE=1'b0;
			SELECT4=1'b0;
		end
		8'd3:begin
			OPCODE=4'd3;	   //for or instruction - 3
			#1		   //one unit delay for generating control signals
			SELECT1=1'b0;
			SELECT2=1'b0;
			SELECT3=1'b0;
			ALUOP=3'd3;	   // or instruction - OR functional unit
			WRITEENABLE=1'b1;
			READ=1'b0;
			WRITE=1'b0;
			SELECT4=1'b0;
		end
		8'd4:begin
			OPCODE=4'd4;	   //for mov instruction - 4
			#1		   //one unit delay for generating control signals
			SELECT1=1'b0;
			SELECT2=1'b0;
			SELECT3=1'b0;
			ALUOP=3'd0;	   // mov instruction - FORWARD functional unit
			WRITEENABLE=1'b1;
			READ=1'b0;
			WRITE=1'b0;
			SELECT4=1'b0;
			
		end
		8'd5:begin
			OPCODE=4'd5;	   //for loadi instruction - 5
			#1		   //one unit delay for generating control signals
			SELECT2=1'b1;	   //to get the IMMEDIATE value
			SELECT1=1'b0;
			SELECT3=1'b0;
			ALUOP=3'd0;	   // loadi instruction - FORWARD functional unit
			WRITEENABLE=1'b1;
			READ=1'b0;
			WRITE=1'b0;
			SELECT4=1'b0;
		end
		8'd6:begin
			OPCODE=4'd6;	   //for jump instruction -6
			#1		   //one unit delay for generating control signals
			SELECT3=1'b1;	   // to get the jump address
			SELECT1=1'b0;
			SELECT2=1'b0;
			WRITEENABLE=1'b0;
			READ=1'b0;
			WRITE=1'b0;
			SELECT4=1'b0;
		end
		8'd7:begin
			OPCODE=4'd7;	   //for branch instruction -7
			#1		   //one unit delay for generating control signals
			SELECT1=1'b1;	   //2s complement
			SELECT2=1'b0;
			SELECT3=1'b1;      //branch address
			ALUOP=3'd1;
			WRITEENABLE=1'b0;
			READ=1'b0;
			WRITE=1'b0;
			SELECT4=1'b0;
		end
		8'd8:begin
			OPCODE=4'd8;	   //for lwd instruction -8
			#1		   //one unit delay for generating control signals
			SELECT1=1'b0;	   //2s complement
			SELECT2=1'b0;	   //immediate value
			SELECT3=1'b0;      //branch address
			ALUOP=3'd0;
			READ=1'b1;	   //read from data mem
			WRITE=1'b0;	   //write to data mem
			SELECT4=1'b1;	   //select between aluresult and readdata
			WRITEENABLE=1'b1;
		end
		8'd9:begin
			OPCODE=4'd9;	   //for lwi instruction -9
			#1		   //one unit delay for generating control signals
			SELECT1=1'b0;	   //2s complement
			SELECT2=1'b1;	   //immediate value
			SELECT3=1'b0;      //branch address
			ALUOP=3'd0;
			READ=1'b1;
			WRITE=1'b0;
			SELECT4=1'b1;
			WRITEENABLE=1'b1;
		end
		8'd10:begin
			OPCODE=4'd10;	   //for swd instruction -10
			#1		   //one unit delay for generating control signals
			SELECT1=1'b0;	   //2s complement
			SELECT2=1'b0;	   //immediate value
			SELECT3=1'b0;      //branch address
			ALUOP=3'd0;
			WRITEENABLE=1'b0;
			READ=1'b0;
			WRITE=1'b1;
			SELECT4=1'b0;
		end
		8'd11:begin
			OPCODE=4'd11;	   //for swi instruction -11
			#1		   //one unit delay for generating control signals
			SELECT1=1'b0;	   //2s complement
			SELECT2=1'b1;	   //immediate value
			SELECT3=1'b0;      //branch address
			ALUOP=3'd0;
			WRITEENABLE=1'b0;
			READ=1'b0;
			WRITE=1'b1;
			SELECT4=1'b0;
		end
		default;
	endcase
	end

	assign #1 COMPLEMENT = ~REGOUT2 + 8'd1;   //2's complement operation on the REGOUT2

	//ADDRESS - given as ALURESULT
	always @(ALURESULT)
	begin
		ADDRESS = ALURESULT;
	end

	//WRITEDATA - given as REGOUT1
	always @(REGOUT1)
	begin
		WRITEDATA = REGOUT1;
	end	

	assign NEWWRITEENABLE = WRITEENABLE & !BUSYWAIT;

	//instantiate the regfile module
	reg_file file1(MUXOUT0,REGOUT1,REGOUT2,WRITEREG,READREG1,READREG2,NEWWRITEENABLE,CLK,RESET);

	//instantiate a mux to select 2nd operand of the ALU is whether 2s complement of REGOUT2 or REGOUT2
	muxto8 mux1(MUX1OUT,SELECT1,COMPLEMENT,REGOUT2);

	//instantiate a mux to select 2nd operand of the ALU is whether IMMEDIATE or MUX1OUT  
	muxto8 mux2(OPERAND2,SELECT2,IMMEDIATE,MUX1OUT);

	//instantiate ALU module
	alu alu1(REGOUT1,OPERAND2,ALURESULT,ALUOP,ZERO);

	//instantiate shiftleft module to get the OFFSET value ,leftshifted by 2
	shiftleft shift1(shiftout,OFFSET);

	//instantiate the extend module to get the OFFSET in 10 bits, extended upto 32 bits
	extend extend1(extendout,shiftout);

	//instantiate i_b_adder module to add the branch jump address and pc
	j_b_adder add(addout,PC0,extendout,INSTRUCTION);

	
	muxto32 mux3(PC2,SELECT3,addout,PC0);
	muxto32 mux4(PC3,ZERO,PC2,PC0);

	//instantiate muxto8 again to select between ALURESULT and READDATA
	muxto8 mux5(MUXOUT0,SELECT4,READDATA,ALURESULT);
	
endmodule


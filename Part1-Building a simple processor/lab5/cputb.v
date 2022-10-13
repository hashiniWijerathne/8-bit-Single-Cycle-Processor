// Computer Architecture (CO224) - Lab 05
// Design: Testbench of Integrated CPU of Simple Processor
// Author: Kisaru Liyanage

`include "cpu.v"

module cpu_tb;

	reg CLK, RESET;
    	wire [31:0] PC;
    	wire [31:0] INSTRUCTION;
    
    /* 
    ------------------------
     SIMPLE INSTRUCTION MEM
    ------------------------
    */
    
    	// TODO: Initialize an array of registers (8x1024) named 'instr_mem' to be used as instruction memory
    	reg [7:0] instr_mem [1023:0];

    	// TODO: Create combinational logic to support CPU instruction fetching, given the Program Counter(PC) value 
    	//       (make sure you include the delay for instruction fetching here)

	assign #2 INSTRUCTION[7:0] = instr_mem[PC];
	assign #2 INSTRUCTION[15:8] = instr_mem[(PC+1)];
	assign #2 INSTRUCTION[23:16] = instr_mem[(PC+2)];
	assign #2 INSTRUCTION[31:24] = instr_mem[PC+3];
	    
    	initial
    	begin
        // Initialize instruction memory with the set of instructions you need execute on CPU
        
        // METHOD 1: manually loading instructions to instr_mem
        //{instr_mem[10'd3], instr_mem[10'd2], instr_mem[10'd1], instr_mem[10'd0]} = 32'b00001010000000000000010000000101;
        //{instr_mem[10'd7], instr_mem[10'd6], instr_mem[10'd5], instr_mem[10'd4]} = 32'b00000001000000000000010100000101;
        //{instr_mem[10'd11], instr_mem[10'd10], instr_mem[10'd9], instr_mem[10'd8]} = 32'b00000001000000000000011000000101;
	//{instr_mem[10'd15], instr_mem[10'd14], instr_mem[10'd13], instr_mem[10'd12]} = 32'b00001001000000000000011100000101;

	//{instr_mem[10'd19], instr_mem[10'd18], instr_mem[10'd17], instr_mem[10'd16]} = 32'b00000101000001000000010000000001;
        //{instr_mem[10'd23], instr_mem[10'd22], instr_mem[10'd21], instr_mem[10'd20]} = 32'b00000110000001000000000100000111;
        //{instr_mem[10'd27], instr_mem[10'd26], instr_mem[10'd25], instr_mem[10'd24]} = 32'b00000000000000001111110100000110;
	//{instr_mem[10'd31], instr_mem[10'd30], instr_mem[10'd29], instr_mem[10'd28]} = 32'b00000111000001000000000100000000;
        
        // METHOD 2: loading instr_mem content from instr_mem.mem file
        	$readmemb("instr_mem.mem", instr_mem);
   	 end
    
    /* 
    -----
     CPU
    -----
    */
    	cpu mycpu(PC, INSTRUCTION, CLK, RESET);

    	initial
    	begin
    
        	// generate files needed to plot the waveform using GTKWave
        	$dumpfile("cpu_wavedata.vcd");
		$dumpvars(0, cpu_tb);
        
        	CLK = 1'b0;
        	RESET = 1'b1;
        
        	// TODO: Reset the CPU (by giving a pulse to RESET signal) to start the program execution
		#5 RESET = 1'b0; //RESET = 1 when positive clock edge
		//#1 RESET = 1'b0; //RESET = 0 in the next positive edge
		
        
        	// finish simulation after some time
        	#300
        	$finish;
        
    	end
    
    	// clock signal generation
    	always
        	#4 CLK = ~CLK;
        

endmodule


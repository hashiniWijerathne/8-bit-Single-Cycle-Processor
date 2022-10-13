`timescale 1ns/100ps

module cache_instruction (clock,reset,PC,instr_busywait,instr_readdata,instr_address,INSTRUCTION,BUSYWAIT_INSTR,instr_read);

	input clock,reset;
	input [31:0] PC;
	output reg BUSYWAIT_INSTR,instr_read;
	output reg [31:0] INSTRUCTION;
	input instr_busywait;

	output reg [5:0] instr_address;
	input [127:0] instr_readdata;
	
	//tag - 3 bits, index - 3 bits, offset - 2 bits (used to seperate the ADDRESS )
	wire [1:0] offset;
	wire [2:0] index,tag;

	//3 bits for each tag & one tag for each block (8 tags all together)
	reg [2:0] tag_array [7:0];
	reg [2:0] block_tag;

	//valid bit, dirty bit (1 dirty bit & 1 valid bit for each block)
	//hit indicates if cpu request is a hit
	reg [7:0] valid_bits;
	reg valid;
	reg hit;

	//Declare cache memory array 32x8-bits 
	reg [127:0] cache_array [7:0];
	reg [127:0] data_block;
	reg [31:0] word;

	wire [9:0] ADDRESS;

	assign ADDRESS = PC[9:0];
	assign offset = ADDRESS[3:2];
	assign index = ADDRESS[6:4];
	assign tag =  ADDRESS[9:7];


	// Combinational part for indexing, tag comparison for hit deciding, etc.
	
	always @(PC,BUSYWAIT_INSTR)
	
	begin
	
		#1
		valid= valid_bits[index];
		block_tag= tag_array[index];
		data_block=cache_array[index];

    		//tag comparison & validation , determining hit or miss
		
		if(block_tag==tag && valid==1) begin
			#0.9 hit=  1; //hit
			BUSYWAIT_INSTR = 0; //busywait deasserted
		end
		
		else begin
			hit=0; //miss
			BUSYWAIT_INSTR=1;
		end
	
	end


		
	//READ HIT
	//always @(data_block,offset) 
	always @(*)
	begin
		//read - selecting the requested word
		#1 //data word selection latency
		
			case(offset)
				2'b00: word = data_block[31:0];
				2'b01: word = data_block[63:32];
				2'b10: word = data_block[95:64];
				2'b11: word = data_block[127:96];
			endcase
							
		
		if(hit) begin
			//sending word back to cpu
			INSTRUCTION = word;	
		end

	end

	
	//WRITE to cache after reading the missed block from instruction memeory
	always @(instr_readdata)
	//always @(posedge clock)
	begin
			
			#1 //latency
			data_block = instr_readdata;
			cache_array[index] = instr_readdata;
			block_tag = tag;
			tag_array[index] = tag;
			valid = 1;
			valid_bits[index] = 1;
		
	end

	/* Cache Controller FSM Start */

	parameter IDLE = 3'b000, MEM_READ = 3'b001;
    	reg [2:0] state, next_state;

    	// combinational next state logic
    	always @(*)
    	begin
        	case (state)

			IDLE:
			begin
        	        if (!hit)  
        	        	next_state = MEM_READ;
        	        else
        	            	next_state = IDLE;
			end
            
        	      	MEM_READ:
			begin
        	        if (!instr_busywait)
        	            next_state = IDLE;
        	        else    
        	            next_state = MEM_READ;
			end
       		 endcase
    	end

    	// combinational output logic
    	always @(*)
    	begin
        	case(state)

            		IDLE:
            		begin
                	instr_read = 0;
			instr_address = 6'dx;
                	BUSYWAIT_INSTR = 0;
            		end
         
            		MEM_READ: 
        	    	begin
                	instr_read = 1;
                	instr_address = {tag, index};
                	BUSYWAIT_INSTR = 1;
            		end
			
        	endcase
    	end

    	

    	// sequential logic for state transitioning 
    	always @(posedge clock, reset)
    	begin
        	if(reset) begin
            		state = IDLE;
			valid_bits = 8'b0; 
			
		end
        	else
            		state = next_state;
    	end

    /* Cache Controller FSM End */
    

endmodule
 

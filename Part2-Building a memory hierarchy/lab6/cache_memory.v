/*
Module  : Data Cache 
Author  : Isuru Nawinne, Kisaru Liyanage
Date    : 25/05/2020

Description	:

This file presents a skeleton implementation of the cache controller using a Finite State Machine model. Note that this code is not complete.
*/

`timescale 1ns/100ps

module cache_memory (clock,reset,READ,WRITE,ADDRESS,WRITEDATA,mem_busywait,mem_readdata,mem_writedata,mem_address,READDATA,busywait,mem_read,mem_write);

	input clock,reset,READ,WRITE;
	input [7:0] ADDRESS,WRITEDATA;
	output reg busywait,mem_read,mem_write;
	output reg [7:0] READDATA;
	input mem_busywait;
	//output read,write;
	output reg [31:0] mem_writedata;
	output reg [5:0] mem_address;
	input [31:0] mem_readdata;
	
	//tag - 3 bits, index - 3 bits, offset - 2 bits (used to seperate the ADDRESS )
	reg [1:0] offset;
	reg [2:0] index;

	//3 bits for each tag & one tag for each block (8 tags all together)
	reg [2:0] tag_array [7:0];
	reg [2:0] block_tag, tag;

	//valid bit, dirty bit (1 dirty bit & 1 valid bit for each block)
	//hit indicates if cpu request is a hit
	reg [7:0] valid_bits,dirty_bits;
	reg valid,dirty,hit;

	//Declare cache memory array 32x8-bits 
	//reg [7:0] cache_array [31:0];
	reg [31:0] cache_array [7:0];
	reg [31:0] data_block;
	reg [7:0] word;

	//for READ & WRITE signals
	reg read,write;

	always @(READ, WRITE)
	begin
		//assert BUSYWAIT when READ or WRITE signal comes to stall the cpu
		busywait = (READ || WRITE)? 1 : 0;
		
		read = (READ || read)? 1 : 0;
		
		write = (write || WRITE)? 1 : 0;
	end

	always @(ADDRESS)
	begin
		offset = ADDRESS[1:0];
		index = ADDRESS[4:2];
		tag =  ADDRESS[7:5];
	end
    
    /*
    Combinational part for indexing, tag comparison for hit deciding, etc.
    */
	//always @(*)
	//begin
	
	always @(ADDRESS,busywait)
	begin
		//extract valid bit,dirty bit,tag and data block according to the index
		#1 //indexing latency
		valid = valid_bits[index];
		dirty = dirty_bits[index];
		block_tag = tag_array[index];
		data_block = cache_array[index];
	
	
		//tag comparison & validation , determining hit or miss
		
		if(block_tag==tag && valid==1) begin
			#0.9 hit=  1; //hit
			busywait = 0; //busywait deasserted
		end
		
		else begin
			 hit=0; //miss
		end
	end
	
	//READ HIT
	always @(data_block,offset) //******offset added 
	begin
		//read - selecting the requested word
		#1 //data word selection latency
		if(read) begin
			
			case(offset)
				2'b00: word = data_block[7:0];
				2'b01: word = data_block[15:8];
				2'b10: word = data_block[23:16];
				2'b11: word = data_block[31:24];
			endcase
						
		end
		
		if(hit) begin
			//sending word back to cpu
			READDATA = word;
			read = 0;
			
		end
	end

	//WRITE HIT
	always @(posedge clock)
	begin
		
		if(write && hit) begin
			#1 //writing latency
			case(offset)
				2'b00: data_block[7:0] = WRITEDATA;
				2'b01: data_block[15:8] = WRITEDATA;
				2'b10: data_block[23:16] = WRITEDATA;
				2'b11: data_block[31:24] = WRITEDATA;
			endcase
			cache_array[index] = data_block;
			//valid bit & dirty bit are set since data was written to cache
			valid = 1;
			valid_bits[index] = 1;
			dirty = 1;
			dirty_bits[index] = 1;
			block_tag = tag;
			tag_array[index] = tag;
			write = 0;
		end
	end

	//WRITE to cache after reading the missed block from data memeory
	always @(mem_readdata)
	begin
		
		#1 //latency
		data_block = mem_readdata;
		cache_array[index] = mem_readdata;
		block_tag = tag;
		tag_array[index] = tag;
		valid = 1;
		valid_bits[index] = 1;
		dirty = 0;
		dirty_bits[index] = 0;
		//busywait = 1;
	end

    	/* Cache Controller FSM Start */

	parameter IDLE = 3'b000, MEM_READ = 3'b001, WRITE_BACK = 3'b010;
    	reg [2:0] state, next_state;

    	// combinational next state logic
    	always @(*)
	//always @(read,write,dirty,hit,mem_busywait)
    	begin
        	case (state)

			IDLE:
			begin
        	        if ((read || write) && !dirty && !hit)  
        	        	next_state = MEM_READ;
        	        else if ((read || write) && dirty && !hit)
        	            	next_state = WRITE_BACK;
        	        else
        	            	next_state = IDLE;
			end
            
        	      	MEM_READ:
			begin
        	        if (!mem_busywait)
        	            next_state = IDLE;
        	        else    
        	            next_state = MEM_READ;
			end

			WRITE_BACK:
			begin
			if (!mem_busywait)
        	            next_state = MEM_READ;
        	        else    
        	            next_state = WRITE_BACK;
			end
            
       		 endcase
    	end

    	// combinational output logic
    	always @(*)
    	begin
        	case(state)
            		IDLE:
            		begin
                	mem_read = 0;
                	mem_write = 0;
                	//mem_address = 8'dx;
                	//mem_writedata = 8'dx;
			mem_address = 6'dx;
                	mem_writedata = 32'dx;
                	busywait = 0;
            		end
         
            		MEM_READ: 
        	    	begin
                	mem_read = 1;
                	mem_write = 0;
                	mem_address = {tag, index};
                	mem_writedata = 32'dx;
                	busywait = 1;
            		end
			
			WRITE_BACK:
			begin
			mem_read = 0;
                	mem_write = 1;
                	mem_address = {block_tag, index};
                	mem_writedata = data_block;
                	busywait = 1;

			end
            
        	endcase
    	end

    	// sequential logic for state transitioning 
    	always @(posedge clock, reset)
    	begin
        	if(reset) begin
            		state = IDLE;
			valid_bits = 8'b0; 
			dirty_bits = 8'b0;
		end
        	else
            		state = next_state;
    	end

    /* Cache Controller FSM End */

endmodule

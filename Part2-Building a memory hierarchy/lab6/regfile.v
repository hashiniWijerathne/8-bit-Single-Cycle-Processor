//group 22
//regfile module

`timescale 1ns/100ps

module reg_file(IN,OUT1,OUT2,INADDRESS,OUT1ADDRESS,OUT2ADDRESS,WRITE,CLK,RESET);

	//ports declaration
	input [7:0] IN; //data to be written 
	input [2:0] INADDRESS,OUT1ADDRESS,OUT2ADDRESS; //register addresses
	input WRITE,CLK,RESET;
	output [7:0] OUT1,OUT2; //data outputs

	reg [7:0] OUT1,OUT2; //out1, out2 declared as reg data type since we assign values to out1 and out2

	reg signed [7:0] registers [7:0]; //8*8 register file created

	//always block to read data inputs
	//reading data happens asynchronously
	always @(OUT1ADDRESS,OUT2ADDRESS,registers[OUT1ADDRESS],registers[OUT2ADDRESS]) begin
		
		#2 //two unites time delay for data reading
		OUT1 =  registers[OUT1ADDRESS]; //data in out1address assigned to out1 after 2 s
		OUT2 =  registers[OUT2ADDRESS]; //data in out1address assigned to out1 after 2 s

	end


	//always block triggered when positive edge of Clock
	//used to reset and write data IN in registers[INADDRESS] synchronously
	always @(posedge CLK) begin

		//first checks if 
		if(RESET) begin //if RESET is 1(reset signal is high) values in all registers should be 0
		
			#1 //one unit time delay for resetting
			registers[0] <=  0;
			registers[1] <=  0;
			registers[2] <=  0;
			registers[3] <=  0;
			registers[4] <=  0;
			registers[5] <=  0;
			registers[6] <=  0;
			registers[7] <=  0;
		end

		else begin 
			if(WRITE) begin //if WRITE is 1(WRITEENABLE signal is high)
				#1 registers[INADDRESS] =  IN; //IN data writes in registers[INADDRESS] with 1 s time delay
			end	
		end
	end

	initial
	begin
		$display("regfile values\n");
		$monitor ($time, "\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d",registers[0],registers[1],registers[2],registers[3],registers[4],registers[5],registers[6],registers[7]);
			
	end	

endmodule

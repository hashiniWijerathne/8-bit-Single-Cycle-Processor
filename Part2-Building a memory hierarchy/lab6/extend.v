//group 22
// module to extend the offset in 10 bits upto 10 bits

`timescale 1ns/100ps

module extend(out,in);

	input [9:0] in;
	output reg [31:0] out;
	always @(in)
	begin
    		out[9:0]=in[9:0];       // last 10 bits assigned as 10 bits of offset
  	  	out[31:10] ={22{in[9]}};// get the 1 st bit(signed bit) of offset and other 22 bits of extended value assigned as signend bit
    //if(in[9]==1) out[31:10]=22'b1111111111111111111111;
    //else out[31:10]=22'd0;
	end
endmodule

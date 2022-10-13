//group 22
// a mux , output port have 32 bits

`timescale 1ns/100ps

module muxto32(out1,select1,in1,in2);

input select1;
input [31:0] in1,in2;
output reg [31:0] out1;
always @(select1,in1,in2)
begin
	if (select1==1)  out1 = in1;
	else out1 = in2;
end
endmodule

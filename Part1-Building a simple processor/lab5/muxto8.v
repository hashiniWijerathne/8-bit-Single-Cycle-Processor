//group 22
// a mux, output port have 8 bits

module muxto8(out,select,in1,in2);

input select;
input [7:0] in1,in2;
output  reg [7:0] out;
always @(select,in1,in2) begin
	if (select==1)  out = in1;
	else out = in2;
end
endmodule

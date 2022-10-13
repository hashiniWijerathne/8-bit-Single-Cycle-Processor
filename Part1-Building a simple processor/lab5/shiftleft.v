//group 22
// module to shift left the offset by 2 

module shiftleft(out,in);

input [7:0] in;
output reg [9:0] out;

always @(in)

begin
    
    out[1:0]=2'd0;    //last two bits set as 0 
    out[9:2]=in[7:0]; //first 8 bits assigned as offset bits
end
endmodule

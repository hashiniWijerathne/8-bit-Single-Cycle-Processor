loadi 4 0x0A  //r4=10
loadi 5 0x01 //r5=1
loadi 6 0x01 //r6=1
loadi 7 0x09 //r7=9
sub 4 4 5 //r4=10-1=9
beq 0x01 4 6 //doesn't branch
j 0xFD //jump -3 -> r4= 9-1=8 ,7,6,5,4,3,2,1
add 1 4 7 //r1=1+9 = 10



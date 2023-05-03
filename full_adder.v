`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/02 10:50:06
// Design Name: 
// Module Name: full_adder
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module full_adder
#(parameter Size = 3072, Size_bi = 72, Size_log = 6)
(
    input [Size+Size_bi+Size_log+1:0] a,// 3152 bits for final QR, 3146 bit for normal QR, 3150 bits for phase_c
    input [Size+Size_bi+Size_log+1:0] b,
    input [Size+Size_bi+Size_log+1:0] cin,
    output [Size+Size_bi+Size_log+1:0] s,
    output [Size+Size_bi+Size_log+1:0] c
    );
    genvar i;
    generate 
        for(i=0;i<Size+Size_bi+Size_log+2;i=i+1) begin: BIT_ADDER
			bit_adder bit_adder(a[i],b[i],cin[i],s[i],c[i]);
		end
	endgenerate
endmodule

module bit_adder(
    a,b,cin,s,c
    );
    input a,b,cin;
    output s,c;
    assign s = a^b^cin;
    assign c = (a&b) | ((a^b)&cin);
endmodule 

module add1
#(parameter Size = 46, radix = 78)
(
	input [Size-1:0] a_0,
	input [Size-1:0] a_1,
	input [Size-1:0] a_2,
	input [Size-1:0] a_3,
	input [Size-1:0] a_4,
	input [Size-1:0] a_5,
	input [Size-1:0] a_6,
	input [Size-1:0] a_7,
	input [Size-1:0] a_8,
	input [Size-1:0] a_9,
	input [Size-1:0] a_10,
	input [Size-1:0] a_11,
	// input [Size-1:0] a_12,
	// input [Size-1:0] a_13,
	// input [Size-1:0] a_14,
	output [radix*2-1:0] res_0,
	output [radix*2-1:0] res_1,
	output [radix*2-1:0] res_2
);
    //need modify depends on the size or the radix
	wire [radix*2-1:0] a_0_w = {110'b0,a_0};
	wire [radix*2-1:0] a_1_w = {90'b0,a_1,20'b0};  
	wire [radix*2-1:0] a_2_w = {70'b0,a_2,40'b0};  
	wire [radix*2-1:0] a_3_w = {84'b0,a_3,26'b0};  
	wire [radix*2-1:0] a_4_w = {64'b0,a_4,46'b0};  
	wire [radix*2-1:0] a_5_w = {44'b0,a_5,66'b0};  
	wire [radix*2-1:0] a_6_w = {58'b0,a_6,52'b0};  
	wire [radix*2-1:0] a_7_w = {38'b0,a_7,72'b0};  
	wire [radix*2-1:0] a_8_w = {18'b0,a_8,92'b0};  
	wire [radix*2-1:0] a_9_w = {32'b0,a_9,78'b0};  
	wire [radix*2-1:0] a_10_w = {12'b0,a_10,98'b0};
	wire [radix*2-1:0] a_11_w = {a_11[37:0],118'b0};
	// wire [radix*2-1:0] a_12_w = {27'b0,a_12,86'b0};
	// wire [radix*2-1:0] a_13_w = {10'b0,a_13,103'b0};
	// wire [radix*2-1:0] a_14_w = {a_14[35:0],120'b0};

	add2_adder_4#(.adder_size(radix*2)) add2_0(a_0_w,a_1_w,a_2_w,a_3_w,res_0);
	add2_adder_4#(.adder_size(radix*2)) add2_1(a_4_w,a_5_w,a_6_w,a_7_w,res_1);
	add2_adder_4#(.adder_size(radix*2)) add2_2(a_8_w,a_9_w,a_10_w,a_11_w,res_2);
endmodule

module add2_adder_5
#(parameter adder_size = 108)
(
	input [adder_size-1:0] a_0,
	input [adder_size-1:0] a_1,
	input [adder_size-1:0] a_2,
	input [adder_size-1:0] a_3,
	 input [adder_size-1:0] a_4,
	output [adder_size-1:0] res
);
	assign res = a_0+a_1+a_2+a_3+a_4;
endmodule

module add2_adder_3
#(parameter adder_size = 108)
(
	input [adder_size-1:0] a_0,
	input [adder_size-1:0] a_1,
	input [adder_size-1:0] a_2,
	output [adder_size-1:0] res
);
	assign res = a_0+a_1+a_2;
endmodule

module add2_adder_4
#(parameter adder_size = 108)
(
	input [adder_size-1:0] a_0,
	input [adder_size-1:0] a_1,
	input [adder_size-1:0] a_2,
	input [adder_size-1:0] a_3,
	output [adder_size-1:0] res
);
	assign res = a_0+a_1+a_2+a_3;
endmodule

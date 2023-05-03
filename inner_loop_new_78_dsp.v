`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/23 21:11:43
// Design Name: 
// Module Name: inner_loop_new_78_dsp
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


module inner_loop_new_78_dsp
#(parameter Size = 3072, radix = 78)
(
	input clk,
	input rst_n,
	input [radix-1:0] bi,
	input [Size+1:0] a,
	input en,
	output reg [Size+radix+1:0] r0,
	output reg [Size+radix+1:0] r1,
	output en_out
    );
	localparam blocks = 20;
	localparam add_size = 43;
	//**********************************

	// integer used for counting
	integer j,p,q,k;
	reg [2:0] cnt;
	
	reg [radix-1:0] multi_a[blocks-1:0];
	// new 108*108 multiplier parameter part and the parameter of the associated adder
	wire [add_size-1:0] multi_res_0[blocks-1:0],multi_res_1[blocks-1:0],multi_res_2[blocks-1:0],multi_res_3[blocks-1:0],multi_res_4[blocks-1:0],multi_res_5[blocks-1:0];
	wire [add_size-1:0] multi_res_6[blocks-1:0],multi_res_7[blocks-1:0],multi_res_8[blocks-1:0],multi_res_9[blocks-1:0],multi_res_10[blocks-1:0],multi_res_11[blocks-1:0];
	wire [add_size-1:0] multi_res_12[blocks-1:0],multi_res_13[blocks-1:0],multi_res_14[blocks-1:0];
	//reg [add_size-1:0] add1_a_0[blocks-1:0],add1_a_1[blocks-1:0],add1_a_2[blocks-1:0],add1_a_3[blocks-1:0],add1_a_4[blocks-1:0],add1_a_5[blocks-1:0];
	//reg [add_size-1:0] add1_a_6[blocks-1:0],add1_a_7[blocks-1:0],add1_a_8[blocks-1:0],add1_a_9[blocks-1:0],add1_a_10[blocks-1:0],add1_a_11[blocks-1:0];
	//reg [add_size-1:0] add1_a_12[blocks-1:0],add1_a_13[blocks-1:0],add1_a_14[blocks-1:0];
	wire [radix*2-1:0] add1_res_0[blocks-1:0],add1_res_1[blocks-1:0],add1_res_2[blocks-1:0];
	reg [radix*2-1:0] add2_a_0[blocks-1:0],add2_a_1[blocks-1:0],add2_a_2[blocks-1:0];
	wire [radix*2-1:0] add2_res[blocks-1:0];
	reg flag;

	always @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			cnt <= 3'd0;
			for(j=0;j<blocks;j=j+1) begin
				multi_a[j] <= 0;
			end/*
			for(p=0;p<blocks;p=p+1) begin
				add1_a_0[p] <= 0;
				add1_a_1[p] <= 0;
				add1_a_2[p] <= 0;
				add1_a_3[p] <= 0;
				add1_a_4[p] <= 0;
				add1_a_5[p] <= 0;
				add1_a_6[p] <= 0;
				add1_a_7[p] <= 0;
				add1_a_8[p] <= 0;
				add1_a_9[p] <= 0;
				add1_a_10[p] <= 0;
				add1_a_11[p] <= 0;
				add1_a_12[p] <= 0;
				add1_a_13[p] <= 0;
				add1_a_14[p] <= 0;
			end*/
			for(q=0;q<blocks;q=q+1) begin
				add2_a_0[q] <= 0;
				add2_a_1[q] <= 0;
				add2_a_2[q] <= 0;
			end
	        // r0 <= 0;
	        // r1 <= 0;
			flag <= 0;

		end
		else begin
		if(en) begin
			cnt <= 3'd1;
			for(j=0;j<blocks;j=j+1) begin
				multi_a[j] <= a[(radix*j)+:radix];
			end
		end
		if(cnt == 3'd1) begin
			cnt <= 3'd2;
			for(j=blocks;j<blocks*2;j=j+1) begin
				if(j == blocks*2 - 1) begin
					multi_a[j-blocks] <= {46'b0,a[3073:3042]};
				end
				else begin
					multi_a[j-blocks] <= a[(radix*j)+:radix];
				end
			end/*
			for(p=0;p<blocks;p=p+1) begin
				add1_a_0[p] <= multi_res_0[p];
				add1_a_1[p] <= multi_res_1[p];
				add1_a_2[p] <= multi_res_2[p];
				add1_a_3[p] <= multi_res_3[p];
				add1_a_4[p] <= multi_res_4[p];
				add1_a_5[p] <= multi_res_5[p];
				add1_a_6[p] <= multi_res_6[p];
				add1_a_7[p] <= multi_res_7[p];
				add1_a_8[p] <= multi_res_8[p];
				add1_a_9[p] <= multi_res_9[p];
				add1_a_10[p] <= multi_res_10[p];
				add1_a_11[p] <= multi_res_11[p];
				add1_a_12[p] <= multi_res_12[p];
				add1_a_13[p] <= multi_res_13[p];
				add1_a_14[p] <= multi_res_14[p];
			end*/
		end
		else if(cnt == 3'd2) begin
			cnt <= 3'd3;/*
			for(p=0;p<blocks;p=p+1) begin
				add1_a_0[p] <= multi_res_0[p];
				add1_a_1[p] <= multi_res_1[p];
				add1_a_2[p] <= multi_res_2[p];
				add1_a_3[p] <= multi_res_3[p];
				add1_a_4[p] <= multi_res_4[p];
				add1_a_5[p] <= multi_res_5[p];
				add1_a_6[p] <= multi_res_6[p];
				add1_a_7[p] <= multi_res_7[p];
				add1_a_8[p] <= multi_res_8[p];
				add1_a_9[p] <= multi_res_9[p];
				add1_a_10[p] <= multi_res_10[p];
				add1_a_11[p] <= multi_res_11[p];
				add1_a_12[p] <= multi_res_12[p];
				add1_a_13[p] <= multi_res_13[p];
				add1_a_14[p] <= multi_res_14[p];
			end*/
			for(q=0;q<blocks;q=q+1) begin
				add2_a_0[q] <= add1_res_0[q];
				add2_a_1[q] <= add1_res_1[q];
				add2_a_2[q] <= add1_res_2[q];
			end
			flag <= 1;
		end
		else if(cnt == 3'd3) begin
			cnt <= 3'd4;
			flag <= 0;
			for(q=0;q<blocks;q=q+1) begin
				add2_a_0[q] <= add1_res_0[q];
				add2_a_1[q] <= add1_res_1[q];
				add2_a_2[q] <= add1_res_2[q];
			end
			// for(k=0;k<blocks;k=k+1) begin
			// 	r0[(radix*k)+:radix] <= add2_res[k][radix-1:0];
			// 	r1[(radix*(k+1))+:radix] <= add2_res[k][radix*2-1:radix];
			// end
		end
        else if(cnt == 3'd4&&~en) cnt <= 0;

		// else if(cnt == 3'd4) begin
		// 	cnt <= 3'd5;
		// 	for(k=blocks;k<blocks*2;k=k+1) begin
		// 		if(k == blocks*2-1) begin
		// 			// special case due to the imbalance partition
		// 			r0[(radix*k)+:radix] <= add2_res[k-blocks][radix-1:0];
		// 			r1[3151:3120] <= add2_res[19][109:78];
		// 		end
		// 		else begin
		// 			r0[(radix*k)+:radix] <= add2_res[k-blocks][radix-1:0];
		// 			r1[(radix*(k+1))+:radix] <= add2_res[k-blocks][radix*2-1:radix];
		// 		end
		// 	end
		// end
		// else if(cnt == 3'd5) begin
		// 	//cnt <= 3'd6;
		// 	for(k=38;k<57;k=k+1) begin
		// 		if(k == 56) begin
		// 			// special case due to the imbalance partition
		// 			r0[(radix*k)+:radix] <= add2_res[18][radix-1:0];
		// 			r1[3127:3078] <= add2_res[18][103:54];
		// 		end
		// 		else begin
		// 			r0[(radix*k)+:radix] <= add2_res[k-38][radix-1:0];
		// 			r1[(radix*(k+1))+:radix] <= add2_res[k-38][radix*2-1:radix];
		// 		end
		// 	end
		// end
	end
	end

	always @(flag) begin
		if(~rst_n) begin
			r0 <= 3152'h0;
			r1 <= 3152'h0;
		end
		/*
		else if(en) begin
			r0 <= 3152'h0;
			r1 <= 3152'h0;
		end
		*/
		else if(flag) begin
			for(k=0;k<blocks;k=k+1) begin
				r0[(radix*k)+:radix] <= add2_res[k][radix-1:0];
				r1[(radix*(k+1))+:radix] <= add2_res[k][radix*2-1:radix];
			end
		end
		else begin
			for(k=blocks;k<blocks*2;k=k+1) begin
				if(k == blocks*2-1) begin
					// special case due to the imbalance partition
					r0[(radix*k)+:radix] <= add2_res[k-blocks][radix-1:0];
					r1[3151:3120] <= add2_res[19][109:78];
				end
				else begin
					r0[(radix*k)+:radix] <= add2_res[k-blocks][radix-1:0];
					r1[(radix*(k+1))+:radix] <= add2_res[k-blocks][radix*2-1:radix];
				end
			end
		end
		
	end

	assign en_out = cnt == 3'd4;
	
	genvar i;
	generate
		for(i=0;i<blocks;i=i+1) begin
			multi multi_n(multi_a[i], bi, clk,multi_res_0[i],multi_res_1[i],multi_res_2[i],multi_res_3[i],multi_res_4[i],multi_res_5[i],multi_res_6[i],multi_res_7[i],multi_res_8[i],multi_res_9[i],multi_res_10[i],multi_res_11[i],multi_res_12[i],multi_res_13[i],multi_res_14[i]);
			add1#(.radix(radix)) add1_n(multi_res_0[i],multi_res_1[i],multi_res_2[i],multi_res_3[i],multi_res_4[i],multi_res_5[i],multi_res_6[i],multi_res_7[i],multi_res_8[i],multi_res_9[i],multi_res_10[i],multi_res_11[i],multi_res_12[i],multi_res_13[i],multi_res_14[i],add1_res_0[i],add1_res_1[i],add1_res_2[i]);
			add2_adder_3#(.adder_size(radix*2)) add2_n(add2_a_0[i], add2_a_1[i],add2_a_2[i], add2_res[i]);
		end
	endgenerate
endmodule

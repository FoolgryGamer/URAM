`timescale 1ns / 1ps

module multiplier
#(parameter mul_size = 80,radix = 78) 
(
	input clk,
	input rst_n,
	input en,
	input [mul_size-1:0] a,
	input [mul_size-1:0] b,
	output [mul_size*2-1:0] res
);
	//***************************
    //Below part need modification manually
    //This part is associated with the number of DSP slice
	wire [19:0] wire_a [3:0];
	wire [19:0] wire_b [3:0];

	//this part needs to be change based on the partition strategy
	assign wire_a[0] = a[19:0];
	assign wire_a[1] = a[39:20];
	assign wire_a[2] = a[59:40];
	assign wire_a[3] = a[79:60];
	assign wire_b[0] = b[19:0];
	assign wire_b[1] = b[39:20];
	assign wire_b[2] = b[59:40];
	assign wire_b[3] = b[79:60];
	
    //used for store the intermediate results
	reg [39:0] out[15:0];
	reg [mul_size*2-1:0] tmp[3:0];
	reg [mul_size*2-1:0] res_t;
	reg [2:0] cnt;

	wire [mul_size*2-1:0] wire_out[15:0];

	assign wire_out[0] = {120'b0,out[0]};
	assign wire_out[1] = {100'b0,out[1],20'b0};
	assign wire_out[2] = {80'b0,out[2],40'b0};
	assign wire_out[3] = {60'b0,out[3],60'b0};
	assign wire_out[4] = {100'b0,out[4],20'b0};
	assign wire_out[5] = {80'b0,out[5],40'b0};
	assign wire_out[6] = {60'b0,out[6],60'b0};
	assign wire_out[7] = {40'b0,out[7],80'b0};
	assign wire_out[8] = {80'b0,out[8],40'b0};
	assign wire_out[9] = {60'b0,out[9],60'b0};
	assign wire_out[10] = {40'b0,out[10],80'b0};
	assign wire_out[11] = {20'b0,out[11],100'b0};
	assign wire_out[12] = {60'b0,out[12],60'b0};
	assign wire_out[13] = {40'b0,out[13],80'b0};
	assign wire_out[14] = {20'b0,out[14],100'b0};
	assign wire_out[15] = {out[15],120'b0};

	// multiply, each cost a dsp slice
	always @(posedge clk) begin
		if(~rst_n) begin
			out[0] <= 0;out[1] <= 0;out[2] <= 0;out[3] <= 0;out[4] <= 0;
			out[5] <= 0;out[6] <= 0;out[7] <= 0;out[8] <= 0;out[9] <= 0;     
			out[10] <= 0;out[11] <= 0;out[12] <= 0;out[13] <= 0;out[14] <= 0;out[15] <= 0;
			res_t <= 0;
			cnt <= 0;
		end
		else begin
			if(en) begin
				cnt <= 3'd1;
				out[0] <= wire_a[0]*wire_b[0];
				out[1] <= wire_a[0]*wire_b[1];
				out[2] <= wire_a[0]*wire_b[2];
				out[3] <= wire_a[0]*wire_b[3];
				out[4] <= wire_a[1]*wire_b[0];
				out[5] <= wire_a[1]*wire_b[1];
				out[6] <= wire_a[1]*wire_b[2];
				out[7] <= wire_a[1]*wire_b[3];
				out[8] <= wire_a[2]*wire_b[0];
				out[9] <= wire_a[2]*wire_b[1];
				out[10] <= wire_a[2]*wire_b[2];
				out[11] <= wire_a[2]*wire_b[3];
				out[12] <= wire_a[3]*wire_b[0];
				out[13] <= wire_a[3]*wire_b[1];
				out[14] <= wire_a[3]*wire_b[2];
				out[15] <= wire_a[3]*wire_b[3];
			end
			else if(cnt == 3'd1) begin
				res_t <= wire_out[0] + wire_out[1] + wire_out[2] + wire_out[3] + wire_out[4] + wire_out[5] + wire_out[6] + wire_out[7] + wire_out[8] + wire_out[9] + wire_out[10] + wire_out[11] + wire_out[12] + wire_out[13] + wire_out[14] + wire_out[15];
				cnt <= 0;
			end
		end
	end
	assign res = res_t;
endmodule

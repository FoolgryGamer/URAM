`timescale 1ns / 1ps

module multiplier_radix
#(parameter mul_size = 80, radix = 78) 
(
	input clk,
	input rst_n,
	input en_multiplier,
	input [mul_size-1:0] reg_m_prime,// 80
	input [2*mul_size-1:0] reg_a_prime,// 160
	input if_last,
	output [radix-1:0] gamma// 78
);
    reg [2:0] cnt;
    reg [(radix+2)*2-1:0] res;
    wire [radix-1:0] gamma_t0;
    wire [radix:0] gamma_t1;
	wire [(radix+2)*2-1:0] res_i0;
    wire [(radix+2)*2-1:0] res_i1;

    reg reg_if_last;
	always @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
            res <= 0;
			cnt <= 0;
			reg_if_last <= 0;
		end
		else begin
			if(en_multiplier) begin
				cnt <= 3'd1;
			end
			else if(cnt == 3'd1) begin
				cnt <= 3'd2;
				reg_if_last <= if_last;
			end
            else if(cnt == 3'd2) begin
                res <= res_i0[(radix+2)*2-1:radix+2] + res_i1;
                cnt <= 0;
            end
		end
	end

    assign gamma_t0 = reg_if_last==0?(res >> (72-6)):(res>>(72+6));
    assign gamma_t1 = gamma_t0+1;
    assign gamma = reg_if_last==0?(gamma_t1[radix-6]?gamma_t0:gamma_t1[radix-1:0]):(gamma_t1[radix]?gamma_t0:gamma_t1[radix-1:0]);
    
	multiplier #(.mul_size(radix+2),.radix(radix)) multiplier_i0(clk,rst_n,en_multiplier,reg_a_prime[radix+1:0],reg_m_prime,res_i0);
    multiplier #(.mul_size(radix+2),.radix(radix)) multiplier_i1(clk,rst_n,en_multiplier,reg_a_prime[(radix+2)*2-1:radix+2],reg_m_prime,res_i1);
endmodule

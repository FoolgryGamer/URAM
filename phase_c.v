`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/21 19:48:19
// Design Name: 
// Module Name: phase_c
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


module phase_c
#(parameter Size = 3072, radix = 72, Size_log = 6, Size_add = 128*25)
(
    input clk,
    input rst_n,
    input [Size+radix+Size_log-1:0] c,
    input [Size-1:0] a,
    input [radix-1:0] bi,
    input en,
    output reg [Size+radix+Size_log-1:0] new_c,
    output reg [2:0] cnt_3,
    output reg en_out
    );
    /******************************en rising edge******************************/
    /*
    reg data_in0;
    reg data_in1;
    assign en_rising_edge=data_in0&~data_in1;

    always@(posedge clk or negedge rst_n or negedge rst_n)begin 
        if(rst_n==1'b0)begin 
            data_in0<=0;
            data_in1<=0;
        end
        else begin 
            data_in0<=en;
            data_in1<=data_in0;
        end
    end
    */
    /*******************************************************************************/
    reg [Size+radix+Size_log-1:0] reg_c;
    reg [Size-1:0] reg_a;
    reg [radix+1:0] reg_m_prime;
    
    reg [2:0] cnt_0;
    reg [2:0] cnt_1;
    
    wire [Size+radix+Size_log+1:0] res_r0_0, res_r1_0;
    wire en_out_inner_loop_0;
    
    reg [Size+radix+Size_log+1:0] a_adder, b_adder, cin_adder;
    wire [Size+radix+Size_log+1:0] s_adder, c_adder;
    reg [Size+radix+Size_log+1:0] reg_s_adder, reg_c_adder;
    reg en_addition;
    wire [Size_add-1:0] c_addition;
    wire en_out_addition;
    
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            reg_c <= 0; reg_a <= 0;
            a_adder <= 0; b_adder <= 0; cin_adder <= 0; 
            en_addition <= 0;
        end
        else begin
            if(en) begin
                reg_c <= c;
                reg_a <= a;
            end 
            if(cnt_1 == 3'd1) begin
                en_addition <= 1'b1;
            end
            if(cnt_1 == 3'd2) begin
                en_addition <= 1'b0;
            end
        end
    end
    //assign en_out = cnt_1 == 3'd4;
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            cnt_0 <= 3'd0;
        end
        else if(en) begin
            cnt_0 <= 3'd1;
        end
        else if(cnt_0 > 3'd0 && cnt_0 < 3'd4) begin
            cnt_0 <= cnt_0 + 1'b1;
        end
        else if(cnt_0 == 3'd4) begin
            cnt_0 <= 3'd0;
        end
    end
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            cnt_1 <= 3'd0;
        end
        else if(cnt_0 == 3'd4) begin
            cnt_1 <= 3'd1;
        end
        else if(cnt_1 > 3'd0 && cnt_1 < 3'd4) begin
            cnt_1 <= cnt_1 + 1'b1;
        end
        else if(cnt_1 == 3'd4) begin
            cnt_1 <= 3'd0;
        end
    end
    /////////////////////////////////////////////////
    reg [2:0] cnt_2;
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            cnt_2 <= 3'd0;
        end
        else if(cnt_1 == 3'd4) begin
            cnt_2 <= 3'd1;
        end
        else if(cnt_2 > 3'd0 && cnt_2 < 3'd4) begin
            cnt_2 <= cnt_2 + 2'b1;
        end
        else if(cnt_2 == 3'd4) begin
            cnt_2 <= 3'd0;
        end
    end
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            cnt_3 <= 3'd0;
        end
        else if(cnt_2 == 3'd4) begin
            cnt_3 <= 3'd1;
        end
        else if(cnt_3 > 3'd0 && cnt_3 < 3'd4) begin
            cnt_3 <= cnt_3 + 2'b1;
        end
        else if(cnt_3 == 3'd4) begin
            cnt_3 <= 3'd0;
        end
    end
    
    reg [Size+radix+Size_log-1:0] temp_c[1:0];
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) temp_c[0] <= 0;
        else if(cnt_2==3'd1) temp_c[0] <= c_addition;
    end
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) temp_c[1] <= 0;
        else if(cnt_3==3'd1) temp_c[1] <= temp_c[0];
    end
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) new_c <= 0;
        else if(cnt_3==3'd4) new_c <= temp_c[1];
    end
    always@(posedge clk or negedge rst_n) begin
        if(~rst_n) en_out <= 0;
        else if(cnt_3==3'd4) en_out <= 1;
        else en_out <= 0;
    end
    
    always@(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            reg_s_adder <= 0;
            reg_c_adder <= 0;
        end
        else if(en_out_inner_loop_0) begin
            reg_s_adder <= s_adder;
            reg_c_adder <= c_adder;
        end
    end
    
    inner_loop_new_78_dsp inner_loop_new_0(clk, rst_n, {6'd0,bi}, {2'd0, a}, en, res_r0_0, res_r1_0, en_out_inner_loop_0);
    
    full_adder#(.Size(Size),.Size_bi(radix),.Size_log(Size_log)) full_adder(res_r0_0,res_r1_0,{2'd0,reg_c},s_adder,c_adder);
    
    addition_3072_128 addition_new({48'd0, reg_s_adder}, {47'd0, reg_c_adder, 1'd0},  clk, rst_n, en_addition, c_addition, en_out_addition);

endmodule


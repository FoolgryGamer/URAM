`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/02 15:52:28
// Design Name: 
// Module Name: phase_a
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

///////////////////////////////////////////////////*from process_a_pipeline_test_2_copy*//////////////////////////////////////////////////

//parameter
//Size_add used for the carry bits(upper bits always be zero)
module phase_a
#(parameter Size = 3072, radix = 72, Size_log = 6, Size_add = 128*25)
(
    input clk,
    input rst_n,
    input [Size+radix+Size_log-1:0] a,
    input [Size-1:0] m,
    input [Size+1:0] m_n,
    input [radix+Size_log+1:0] m_prime,
    input en,
    input if_last,
    output reg [Size-1:0] new_a,
    output reg [2:0] cnt_4,
    output en_out
    );

    /******************************enable rising edge******************************/
    // the enable signal is en_rising_edge
    /*
    reg enable_in0;
    reg enable_in1;
    assign en_rising_edge=enable_in0&~enable_in1;

    always@(posedge clk or negedge rst_n or negedge rst_n)begin 
        if(rst_n==1'b0)begin 
            enable_in0<=0;
            enable_in1<=0;
        end
        else begin 
            enable_in0<=en;
            enable_in1<=enable_in0;
        end
    end
    */
    /*******************************************************************************/
    //used for pipeline,store the value of A
    reg [Size+radix+Size_log-1:0] reg_a, reg_a_1;// 3072+72+6=3150   
    reg [radix+Size_log+1:0] reg_m_prime;// 72+6+2=80
    reg [(radix+Size_log)*2+1:0] reg_a_prime;// (72+6)*2+2=158
    //count for each pipeline
    reg [2:0] cnt_0;
    reg [2:0] cnt_1;
    reg [2:0] cnt_2;
    reg [2:0] cnt_3;
    
    wire [radix+Size_log-1:0] gamma;

    //multiplier
    reg en_multiplier;
    //inner_loop enable signal and output
    reg en_inner_loop;
    wire [Size+radix+Size_log+1:0] res_r0, res_r1;
    wire en_out_inner_loop;

    //full_adder signal and output
    reg [Size+radix+Size_log+1:0] a_adder, b_adder, cin_adder;//3072+72+6+2=3152
    wire [Size+radix+Size_log+1:0] s_adder, c_adder;

    //addition enable signal and output
    reg en_addition_0;
    wire [Size_add-1:0] gamma_m_mul;
    wire en_out_addition_0;
    reg en_addition_1;
    wire [Size_add-1:0] c_addition_1;
    reg [Size_add-1:0] b_addition_1;
    reg [Size+1:0] c_res;
    wire  en_out_addition_1;

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            reg_a <= 0;
            reg_a_prime <= 0;
            en_inner_loop <= 0;
            a_adder <= 0; b_adder <= 0; cin_adder <= 0; 
            en_addition_0 <= 0;
            en_addition_1 <= 0;
            en_multiplier <= 1'b0;
            c_res <= 0;
        end
        else begin
            if(en) begin
                if(if_last) begin
                    reg_m_prime <= m_prime;
                    reg_a_prime <= a[(Size+radix+Size_log-1)-:(2*radix+2*Size_log+2)];
                end
                else begin
                    reg_m_prime <= m_prime>>Size_log;
                    reg_a_prime <= {6'd0, a[(Size+radix-1)-:(2*radix+2)]};
                end
                en_multiplier <= 1'b1;
            end
            if(cnt_0 == 3'd1) begin
                en_multiplier <= 1'b0;
            end
            else if(cnt_0 == 3'd3) begin
                en_inner_loop <= 1'b1;
                reg_a <= {1'd0, a};
            end
            else if(cnt_0 == 3'd4) begin
                en_inner_loop <= 1'b0;
            end
            if(cnt_1 == 3'd3) begin
                reg_a_1 <= reg_a;
            end
            if(cnt_2 == 3'd1) begin  
                a_adder <= {2'd0,reg_a_1};
                b_adder <= res_r0;
                cin_adder <= res_r1;
                en_addition_0 <= 1'b1;
            end
            else if(cnt_2 == 3'd2) begin  
                en_addition_0 <= 1'b0;
            end
            if(cnt_3 == 3'd1) begin             
                if(gamma_m_mul[Size+1]) begin
                    b_addition_1 <= {128'd0, m};
                end
                else begin
                    b_addition_1 <= {126'd0, m_n};
                end
                en_addition_1 <= 1'b1;
            end
            else if(cnt_3 == 3'd2) begin       
                c_res <= gamma_m_mul[Size+1:0];
                en_addition_1 <= 1'b0;
            end
        end
    end

    assign en_out = cnt_4 == 3'd3;

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
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            cnt_2 <= 3'd0;
        end
        else if(cnt_1 == 3'd4) begin
            cnt_2 <= 3'd1;
        end
        else if(cnt_2 > 3'd0 && cnt_2 < 3'd4) begin
            cnt_2 <= cnt_2 + 1'b1;
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
        else if(cnt_3 > 3'd0 && cnt_3 < 3'd2) begin
            cnt_3 <= cnt_3 + 1'b1;
        end
        else if(cnt_3 == 3'd2) begin
            cnt_3 <= 3'd0;
        end
    end
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            cnt_4 <= 3'd0;
        end
        else if(cnt_3 == 3'd2) begin
            cnt_4 <= 3'd1;
        end
        else if(cnt_4 > 3'd0 && cnt_4 < 3'd3) begin
            cnt_4 <= cnt_4 + 1'b1;
        end
        else if(cnt_4 == 3'd3) begin
            cnt_4 <= 3'd0;
        end
    end

    always @(*) begin
        case (cnt_4)
            3'd3: new_a = c_addition_1[Size+1]?c_res:c_addition_1;
            default: ;
        endcase
    end

    //cnt_0
    multiplier_radix multiplier_0(clk,rst_n,en_multiplier,{2'd0,reg_m_prime},{2'd0,reg_a_prime},if_last,gamma);// 72*146 (78*158) output:78
    //cnt_1
    inner_loop_new_78_dsp inner_loop_new(clk, rst_n, gamma, m_n, en_inner_loop, res_r0, res_r1, en_out_inner_loop);
    //cnt_2
    full_adder #(.Size(Size),.Size_bi(radix),.Size_log(Size_log)) full_adder(a_adder,b_adder,cin_adder,s_adder,c_adder);
    //cnt_3    big number addition
    addition_3072_128 addition_0({48'd0, s_adder}, {47'd0, c_adder, 1'd0},  clk, rst_n, en_addition_0, gamma_m_mul, en_out_addition_0);
    //cnt_4
    addition_3072_128 addition_1(gamma_m_mul, b_addition_1,  clk, rst_n, en_addition_1, c_addition_1,  en_out_addition_1);
    //addition_new addition_new_2(gamma_m_mul, {253'd0, m_n,1'd0},  clk, rst_n, en_addition_1, c_addition_2,  en_out_addition_2);
    
endmodule

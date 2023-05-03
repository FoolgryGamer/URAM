`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/26 00:52:11
// Design Name: 
// Module Name: stage_num_counter
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


module stage_num_counter(
    input clk,
    input rst_n,
    input [1:0] stage_num_in,
    input en_a,
    input en_c,
    input en_out_a,
    input en_out_c,
    input [2:0] cnt_4,
    input [2:0] cnt_3,
    input [7:0] mm_info_in,
    output reg [7:0] mm_info_out,
    output reg [1:0] stage_num_out
    );
    wire en_out =en_out_a||en_out_c;
    wire en= en_a||en_c; 
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

    ////////////////////////////////////////////////////////
    reg [1:0] stage_num [3:0];
    reg [7:0] reg_mm_info [3:0];
    reg [1:0] cnt_num_in, cnt_num_out;
    always@(posedge clk or negedge rst_n) begin
        if(~rst_n) cnt_num_in <= 2'd0;
        else if(en) begin
            cnt_num_in <= cnt_num_in+1'b1;
        end
    end
    always@(posedge clk or negedge rst_n) begin
        if(~rst_n) cnt_num_out <= 2'd0;
        else if(en_out) begin
            cnt_num_out <= cnt_num_out+1'b1;
        end
    end
    always@(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            stage_num[0] <= 0;
            stage_num[1] <= 0;
            stage_num[2] <= 0;
            stage_num[3] <= 0;
            reg_mm_info[0] <= 0;
            reg_mm_info[1] <= 0;
            reg_mm_info[2] <= 0;
            reg_mm_info[3] <= 0;
        end
        else begin
            if(en) begin
                stage_num[cnt_num_in] <= stage_num_in;
                reg_mm_info[cnt_num_in] <= mm_info_in;
            end
        end
    end
    always@(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            stage_num_out <= 0;
            mm_info_out <= 0;
        end
        else if((cnt_4==3'd2)||(cnt_3==3'd4)) begin
            stage_num_out <= stage_num[cnt_num_out];
            mm_info_out <= reg_mm_info[cnt_num_out];
        end
    end
    ///////////////////////////////////////////////////////
endmodule

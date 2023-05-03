`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/21 10:27:46
// Design Name: 
// Module Name: pipelined_mm
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


module pipelined_mm
#(
    parameter M_SIZE = 3072,
    parameter RADIX = 72,
    parameter SIZE_LOG = 6
)(
    input clk,
    input rst_n,
    input en,
    
    input [M_SIZE+RADIX+SIZE_LOG-1:0] last_z,
    input [M_SIZE+RADIX+SIZE_LOG-1:0] last_a,
    input [M_SIZE-1:0] a,
    input [M_SIZE-1:0] b,
    input [M_SIZE-1:0] m,
    input [M_SIZE+1:0] m_n,
    input [RADIX+SIZE_LOG+1:0] m_prime,
    input en_out_a,
    input en_out_z,
    
    output reg [M_SIZE+RADIX+SIZE_LOG-1:0] now_z,
    output reg [M_SIZE-1:0] now_a,
    output reg [M_SIZE+RADIX+SIZE_LOG-1:0] now_a_to_QR,
    output reg [RADIX-1:0] now_bi,
    output reg en_z,
    output reg en_a,
    output reg if_last,
    
    input [1:0] stage_num_in,// indicate which stage is used by the mm
    input [7:0] mm_info_in,
    input [7:0] mm_info_ini_in,
    output reg [7:0] mm_info_out,
    
    output reg [3:0] flag,//four stages in pipeline, 1=occupied, 0=available
    output reg [1:0] stage_num_out,// indicate which stage is used by the mm
    output reg [4:0] round,// nonstop counting
    output reg busy,
    output full,
    output reg done
    );
    assign full=flag[0]&&flag[1]&&flag[2]&&flag[3];
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            flag <= 4'd0;
        end
        else if(en==1) begin
            if(round==0) begin 
                flag[0] <= 1'b1;
            end
            else if(round==4) begin
                flag[1] <= 1'b1;
            end
            else if(round==8) begin
                flag[2] <= 1'b1;
            end
            else if(round==12) begin
                flag[3] <= 1'b1;
            end
        end
        else if(done) begin
            flag[stage_num_in] <= 1'b0;
        end
    end
    
    reg en_delay;
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            en_delay <= 0;
        end
        else begin
            en_delay <= en;
        end
    end
    
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            round <= 5'd0;
        end
        else if(round < 5'd17) begin
            round <= round+1'b1;
        end
        else begin
            round <= 5'd0;
        end
    end
    
    reg [M_SIZE-1:0] reg_b [3:0];
    
    
    always@(posedge clk or negedge rst_n or negedge rst_n) begin
        if(~rst_n) begin
            en_z <= 1'b0;
            en_a <= 1'b0;
            if_last <= 1'b0;// if last QR
            busy <= 1'b0;
            stage_num_out <= 2'd0;
            now_z <= 0;
            now_a <= 0;
            now_a_to_QR <= 0;
            now_bi <= 0; 
            reg_b[0] <= 0;
            reg_b[1] <= 0;
            reg_b[2] <= 0;
            reg_b[3] <= 0;
            mm_info_out <= 0;
        end
        else if(en) begin
            if(round==0) begin 
                stage_num_out <= 2'd0;
            end
            else if(round==4) begin
                stage_num_out <= 2'd1;
            end
            else if(round==8) begin
                stage_num_out <= 2'd2;
            end
            else if(round==12) begin
                stage_num_out <= 2'd3;
            end
        end
        else if(en_delay) begin
            en_z <= 1'b1;
            if(b>>RADIX!=0) en_a <= 1'b1;
            if_last <= 1'b1;// if last QR
            now_z <= 0;
            now_a <= a;
            now_a_to_QR <= a<<RADIX;
            now_bi <= b[RADIX-1:0];
            
            reg_b[stage_num_out] <= b>>RADIX;
            
            busy <= 1'b1;
            
            mm_info_out <= mm_info_ini_in;
        end
        else if(busy) begin
            if(en_out_a && reg_b[stage_num_in]==0) begin//最后一个QR完成
                now_z <= last_a;
                if(flag==4'b0001||flag==4'b0010||flag==4'b0100||flag==4'b1000) busy <= 0;
            end
            else if(en_out_z && reg_b[stage_num_in]==0) begin//执行最后一个QR, 最后一个c+bia完成
                en_a <= 1'b1;
                if_last <= 1'b1;// if last QR
                now_z <= last_z;
                now_a_to_QR <= last_z;
                
                stage_num_out <= stage_num_in;/////////////////
                
                mm_info_out <= mm_info_in;
            end
            else if(en_out_a) begin//正常执行模乘前部分
                if(reg_b[stage_num_in]>>RADIX==0) begin//执行最后一个c+bia
                    en_z <= 1'b1;
                    now_z <= last_z;
                    now_a <= last_a;
                    now_bi <= reg_b[stage_num_in][RADIX-1:0];
                    reg_b[stage_num_in] <= reg_b[stage_num_in]>>RADIX;
                    
                    stage_num_out <= stage_num_in;/////////////////
                    
                    mm_info_out <= mm_info_in;
                end
                else begin
                    en_z <= 1'b1;
                    en_a <= 1'b1;
                    if_last <= 1'b0;// if last QR
                    now_z <= last_z;
                    now_a <= last_a;
                    now_a_to_QR <= last_a<<RADIX;
                    now_bi <= reg_b[stage_num_in][RADIX-1:0];
                    reg_b[stage_num_in] <= reg_b[stage_num_in]>>RADIX;
                    
                    stage_num_out <= stage_num_in;/////////////////
                    
                    mm_info_out <= mm_info_in;
                end
            end
            else begin
                en_z <= 1'b0;
                en_a <= 1'b0;
            end
        end
    end
    
    always@(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            done <= 0;
        end
        else if(busy&&en_out_a && reg_b[stage_num_in]==0) begin
            done <= 1'b1;
        end
        else begin
            done <= 0;
        end
    end
endmodule

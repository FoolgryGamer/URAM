`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/24 17:30:44
// Design Name: 
// Module Name: uram_read
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


module uram_read#(
    parameter WIDTH=3072,
    parameter URAM_ADDR=12
)(
    input clk,
    input rst_n,
    input en_pre_me,
    input [WIDTH-1:0] e,
        
    input wfull,
    output [WIDTH-1:0] data_fifo,
    output reg write_fifo,
    
    input [WIDTH-1:0] data_uram,
    output reg rd_uram,
    output reg [URAM_ADDR-1:0] rd_addr,
    output scanning_e
    );
    reg rd_delay0;
    reg [WIDTH-1:0] reg_e;
    reg busy;
    
    assign data_fifo=data_uram;
    assign scanning_e = reg_e!=0 || busy;
    
    always@(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            rd_delay0 <= 0;
            write_fifo <= 0;
        end
        else begin
            rd_delay0 <= rd_uram;
            write_fifo <= rd_delay0;
        end
    end
    
    always@(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            busy <= 0;
        end
        else if(reg_e!=0 && !wfull && !busy && reg_e[rd_addr]==1'b1) begin
            busy <= 1;
        end
        else if(write_fifo) begin
            busy <= 0;
        end
    end
    
    
    always@(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            reg_e <= 0;
            rd_addr <= 0;
            rd_uram <= 0;
        end
        else if(en_pre_me) begin
            reg_e <= e;
            rd_addr <= 0;
            rd_uram <= 0;
        end
        else if(reg_e!=0) begin
            if(rd_uram) begin
                reg_e[rd_addr] <= 0;
                rd_addr <= rd_addr+1'b1;
                rd_uram <= 0;
            end
            else if(!wfull && !rd_uram) begin
                if(reg_e[rd_addr]==1'b1) begin
                    if(!busy) rd_uram <= 1;
                end
                else begin
                    rd_uram <= 0;
                    rd_addr <= rd_addr+1'b1;
                end
            end
            else begin
                rd_uram <= 0;
            end
        end
        else begin
            rd_uram <= 0;
        end
    end
    
endmodule

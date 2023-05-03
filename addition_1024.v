`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/14 12:26:51
// Design Name: 
// Module Name: addition_1024
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


module addition_3072_128
#(parameter Block = 128, Size_add = Block*25, Size_c0 = 25, Size_c1 = 24)
(
    input [Size_add-1:0] a,
    input [Size_add-1:0] b,
    input clk,
    input rst_n,
    input en,
    output [Size_add-1:0] c,
    //output reg c_top,
    output reg en_out
    );
    reg [11:0] reg_length;
    reg [Block-1:0] reg_c[Size_c0-1:0];
    assign c = {reg_c[24], reg_c[23], reg_c[22], reg_c[21], reg_c[20], reg_c[19], reg_c[18], reg_c[17], reg_c[16], reg_c[15], reg_c[14], reg_c[13], reg_c[12], reg_c[11], reg_c[10], reg_c[9], reg_c[8], reg_c[7], reg_c[6], reg_c[5], reg_c[4], reg_c[3], reg_c[2], reg_c[1], reg_c[0]};
    wire [Block:0] cout[Size_c0-1:0];
    reg [Block:0] c_0[Size_c0-1:0];
    reg [Block:0] c_1[Size_c0-1:0];
    
    
    reg cin;
    reg [1:0] flag;
    integer i;
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            for(i=0;i<Size_c0;i=i+1) begin
                reg_c[i] = 0;
            end
        end
        else if(flag==2'b11) begin
            reg_c[0] = c_0[0][Block-1:0];
            cin = c_0[0][Block];
            for(i=1;i<Size_c0;i=i+1) begin
                if(cin==1) begin
                    reg_c[i] = c_1[i][Block-1:0];
                    cin = c_1[i][Block];
                end
                else begin
                    reg_c[i] = c_0[i][Block-1:0];
                    cin = c_0[i][Block];
                end
            end
        end
    end
    
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            en_out <= 0;
        end
        else if(flag==2'b11) begin
            en_out <= 1;
        end
        else begin
            en_out <= 0;
        end
    end
    
    integer j;
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            flag <= 2'b00;
            for(j=0;j<Size_c0;j=j+1) begin
                c_0[j] <= 0;
            end
        end
        else if(en) begin
            for(j=0;j<Size_c0;j=j+1) begin
                c_0[j] <= cout[j];
            end
            flag <= 2'b01;
        end
        else if(flag==2'b01) begin
            for(j=0;j<Size_c0;j=j+1) begin
                c_1[j] <= cout[j];
            end
            flag <= 2'b11;
        end
        else if(flag==2'b11) begin
            flag <= 2'b00;
        end
    end
    
    genvar p;
    generate
        for(p=0;p<Size_c0;p=p+1) begin
            unit_adder unit_adder_0(a[Block*p+:Block], b[Block*p+:Block], flag[0], cout[p]);
        end
    endgenerate 
endmodule

module unit_adder
#(parameter Block = 128)
(
    input [Block-1:0] a,
    input [Block-1:0] b,
    input cin,
    output [Block:0] c
);
    assign c = a+b+cin;
endmodule

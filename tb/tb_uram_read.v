`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/26 21:17:25
// Design Name: 
// Module Name: tb_uram_read
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


module tb_uram_read#(
    parameter M_SIZE=3072,
    parameter URAM_ADDR=12
)(

    );
    reg clk, rst_n, en_pre_me;
    reg [M_SIZE-1:0] e;
    wire [M_SIZE-1:0] reg_e;
    reg wfull;
    wire [M_SIZE-1:0] data_fifo;
    wire write_fifo;
    reg [M_SIZE-1:0] data_uram;
    wire rd_uram;
    wire [URAM_ADDR-1:0] rd_addr;
    
    initial begin
        clk = 0;
        rst_n = 0;
        en_pre_me = 0;
        wfull = 0;
        data_uram = 0;
        #20
        rst_n = 1;
        #20
        en_pre_me = 1;
        e = 6'b100101;
        #10
        en_pre_me = 0;
    end
    
    always#5 clk = !clk;
    
uram_read #(
    .WIDTH(M_SIZE),
    .URAM_ADDR(URAM_ADDR)
)uram_read(
    .clk(clk),
    .rst_n(rst_n),
    .en_pre_me(en_pre_me),
    .e(e),
    
    .reg_e(reg_e),
    
    .wfull(wfull),
    .data_fifo(data_fifo),
    .write_fifo(write_fifo),
    
    .data_uram(data_uram),
    .rd_uram(rd_uram),
    .rd_addr(rd_addr)
);
endmodule

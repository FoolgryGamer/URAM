`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/21 11:36:46
// Design Name: 
// Module Name: table_manager
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


module table_manager#(
    parameter WIDTH = 3072,
    parameter DEPTH = 4,
    parameter Width_addr = 2,
    //parameter test_num = 1000,
    parameter URAM_ADDR = 12
)(
    input clk,
    input rst_n,
    input en_pre_me,
    input [WIDTH-1:0] e,
    input rinc,
    output [WIDTH-1:0] rdata,
    output rempty,
    output scanning_e
    );
    wire winc;
    wire [WIDTH-1:0] wdata;
    wire wfull;
    wire rd_uram;
    wire [URAM_ADDR-1:0] rd_addr;
    wire [WIDTH-1:0] data_uram;
SyncFIFO #(
    .WIDTH(WIDTH),
    .DEPTH(DEPTH),
    .Width_addr(Width_addr)
) SyncFIFO_0 (
    .clk(clk), 
    .rst_n(rst_n),
    .winc(winc),
    .rinc(rinc),
    .wdata(wdata),

    .wfull(wfull),
    .rempty(rempty),
    .rdata(rdata)
);
/*
template_write #(
    .WIDTH(WIDTH),
    .DEPTH(DEPTH),
    .Width_addr(Width_addr),
    .test_num(test_num)
) template_write_0 (
    .clk(clk),
    .rst_n(rst_n),
    .wfull(wfull),
    .winc(winc),
    .wdata(wdata)
    );
*/

template_uram#(
    .WIDTH(WIDTH),
    .URAM_ADDR(URAM_ADDR)
)template_uram(
    .clk(clk),
    .rst_n(rst_n),
    .rd_uram(rd_uram),
    .rd_addr(rd_addr),
    .data_uram(data_uram)
);

uram_read #(
    .WIDTH(WIDTH),
    .URAM_ADDR(URAM_ADDR)
)uram_read(
    .clk(clk),
    .rst_n(rst_n),
    .en_pre_me(en_pre_me),
    .e(e),
        
    .wfull(wfull),
    .data_fifo(wdata),
    .write_fifo(winc),
    
    .data_uram(data_uram),
    .rd_uram(rd_uram),
    .rd_addr(rd_addr),
    .scanning_e(scanning_e)
);
endmodule

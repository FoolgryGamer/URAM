`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/21 11:35:48
// Design Name: 
// Module Name: SyncFIFO
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


module SyncFIFO#(
    parameter  WIDTH = 3072,
    parameter   DEPTH = 4,
    parameter Width_addr = 2
)(
    input           clk, 
    input           rst_n,
    input           winc,
    input            rinc,
    input     [WIDTH-1:0]  wdata,

    output         wfull,
    output         rempty,
    output [WIDTH-1:0]  rdata
);
    //function integer clog2;
    //input integer value;
    //begin
    //    value = value-1;
    //    for (clog2=0; value>0; clog2=clog2+1)
    //        value = value>>1;
    //end
    //endfunction

    reg [Width_addr:0] waddr;
    reg [Width_addr:0] raddr;
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            waddr <= 1'b0;
        end 
        else begin
            if( winc && ~wfull ) begin
                waddr <= waddr + 1'b1;
            end 
            else begin
                waddr <= waddr;    
            end 
        end 
    end 

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            raddr <= 1'b0;
        end 
        else begin
            if( rinc && ~rempty ) begin
                raddr <= raddr + 1'b1;
            end 
            else begin
                raddr <= raddr;    
            end 
        end 
    end 

    assign wfull = (raddr == {~waddr[Width_addr], waddr[Width_addr-1:0]});
    assign rempty = (raddr == waddr);

// 带有 parameter 参数的例化格式    
dual_port_RAM  
    #(
        .DEPTH(DEPTH),
        .WIDTH(WIDTH),
        .Width_addr(Width_addr)
    )
    dual_port_RAM_U0 
    (
        .wclk(clk),
        .rst_n(rst_n),
        .wenc(winc),
        .waddr(waddr[Width_addr-1:0]), 
        .wdata(wdata),        
        .rclk(clk),
        .renc(rinc),
        .raddr(raddr[Width_addr-1:0]), 
        .rdata(rdata)     
);       
endmodule

/**************RAM 子模块*************/
module dual_port_RAM #(
    parameter DEPTH = 4,
    parameter WIDTH = 3072,
    parameter Width_addr = 2)(
    input wclk,
    input rst_n,
    input wenc,// 写使能
    input [Width_addr-1:0] waddr,  //写地址
    input [WIDTH-1:0] wdata,        //数据写入
    input rclk,
    input renc,// 读使能
    input [Width_addr-1:0] raddr,  //读地址
    output reg [WIDTH-1:0] rdata     //数据输出
);

reg [WIDTH-1:0] RAM_MEM [0:DEPTH-1];

always @(posedge wclk) begin
    if(wenc) RAM_MEM[waddr] <= wdata;
end 

always @(posedge rclk or negedge rst_n) begin
    if(~rst_n) rdata <= 0;
    else if(renc) rdata <= RAM_MEM[raddr];
end 

endmodule
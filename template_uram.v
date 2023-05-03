`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/27 10:39:39
// Design Name: 
// Module Name: template_uram
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


module template_uram#(
    parameter  WIDTH = 3072,
    parameter URAM_ADDR=12
)(
    input clk,
    input rst_n,
    input rd_uram,
    input [URAM_ADDR-1:0] rd_addr,
    output reg [WIDTH-1:0] data_uram
    );
    reg rd_delay;
    always@(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            rd_delay <= 0;
        end
        else begin
            rd_delay <= rd_uram;
        end
    end
    reg [1:0] tmp;
    always@(posedge clk or negedge rst_n ) begin
        if(~rst_n) begin
            data_uram <= 0;
            tmp <= 0;
        end
        else if(rd_delay) begin
            data_uram <= {tmp, 3070'h2537b809d650de8821a83a5433a9d61aede0b5920116118d86fb93a8d61ff5a55a3e1a86a9120ba88af0ff4819be8672a58ecbc4400842af1066a7b2e35e526d9ab97bd64db7bff40899184841441aa17a2d7841cf20bc9a5fc943298506d301af280f381f7926c35def357682db8c4db8efe60f0aa935118ab780d2973963903eb6d14bb6540990f80c8061362db2be2bf1cc084dce716c58cca95c5cd0c1b936019cd4759e88ad73f4da76a03fbeef68cb9e02460732361921f86cce6536ba073754de30ed0e06ed36943c5ec050f7ddd4257fbb5af45a6f419c93f11cd49134357a0be4edc9ec3ca2f8b87afa9fa492ab0d79195a0fee32d288531fef019fa0c99c50fed25f253cb31035ef94ecbf2d1565bdc8cc519313cbef7757b04f50f8ca834effd0688af300f3659a9447316b59e67540d31c8be01cb54ecae0e8ca60cf668014db967669e48796ecd0807113b29d0a42eb574f2e554879c44eb5d200585ffbd15b31f5f7a0a3a557a31bc8400bf88f4748907725c7be2d13da5531};
            tmp <= tmp+1;
        end
    end
    
endmodule

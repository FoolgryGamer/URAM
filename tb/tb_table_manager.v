`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/27 16:57:37
// Design Name: 
// Module Name: tb_table_manager
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


module tb_table_manager#(
    parameter WIDTH = 3072,
    parameter DEPTH = 4,
    parameter Width_addr = 2,
    parameter test_num = 1000,
    parameter URAM_ADDR = 12
)(
    );
    reg clk, rst_n, en_pre_me;
    reg [WIDTH-1:0] e;
    reg rinc;
    wire [WIDTH-1:0] rdata;
    wire rempty;
    
    initial begin
        clk = 0;
        rst_n = 0;
        en_pre_me = 0;
        e = 0;
        rinc = 0;
        #10
        rst_n = 1;
        #40
        en_pre_me = 1;
        e = 8'b10101110;
        #10
        en_pre_me = 0;
        #35
        //rinc = 1;
        #10
        //rinc = 1;
        #10
        rinc = 1;
        #10
        rinc = 0;
    end
    
    wire flag = rdata=={2'b00, 3070'h2537b809d650de8821a83a5433a9d61aede0b5920116118d86fb93a8d61ff5a55a3e1a86a9120ba88af0ff4819be8672a58ecbc4400842af1066a7b2e35e526d9ab97bd64db7bff40899184841441aa17a2d7841cf20bc9a5fc943298506d301af280f381f7926c35def357682db8c4db8efe60f0aa935118ab780d2973963903eb6d14bb6540990f80c8061362db2be2bf1cc084dce716c58cca95c5cd0c1b936019cd4759e88ad73f4da76a03fbeef68cb9e02460732361921f86cce6536ba073754de30ed0e06ed36943c5ec050f7ddd4257fbb5af45a6f419c93f11cd49134357a0be4edc9ec3ca2f8b87afa9fa492ab0d79195a0fee32d288531fef019fa0c99c50fed25f253cb31035ef94ecbf2d1565bdc8cc519313cbef7757b04f50f8ca834effd0688af300f3659a9447316b59e67540d31c8be01cb54ecae0e8ca60cf668014db967669e48796ecd0807113b29d0a42eb574f2e554879c44eb5d200585ffbd15b31f5f7a0a3a557a31bc8400bf88f4748907725c7be2d13da5531};

    always#5 clk = ~clk;
    
table_manager#(
    .WIDTH(WIDTH),
    .DEPTH(DEPTH),
    .Width_addr(Width_addr),
    .test_num(0),
    .URAM_ADDR(URAM_ADDR)
)table_manager_0(
    .clk(clk),
    .rst_n(rst_n),
    .en_pre_me(en_pre_me),
    .e(e),
    .rinc(rinc),
    .rdata(rdata),
    .rempty(rempty)
);
endmodule

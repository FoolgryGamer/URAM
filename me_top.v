`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/21 10:36:13
// Design Name: 
// Module Name: me_top
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


module me_top#(
    parameter M_SIZE = 3072,
    parameter RADIX = 72,
    parameter SIZE_LOG = 6,
    parameter FIFO_DEPTH = 4,
    parameter FIFO_AddrWidth = 2,
    parameter SIZE_ADD = 128*25,
    parameter URAM_ADDR = 12
)(
    input clk,
    input rst_n,
    input en_pre_me,
    input en_me,
    input en_one_mm,
    input [3:0] num,
    
    input [M_SIZE-1:0] a,
    input [M_SIZE-1:0] e,
    input [M_SIZE-1:0] m,
    input [M_SIZE+1:0] m_n,
    input [RADIX+SIZE_LOG+1:0] m_prime,
    
    output [M_SIZE-1:0] z,
    output [3:0] num_out,
    output done
    );
    
    wire mm_full, mm_busy, mm_done;
    wire [3:0] mm_flag;
    wire [4:0] mm_round;
    wire [M_SIZE-1:0] new_c;
    wire [7:0] mm_info_out, mm_info_in;
    wire en_mm;
    wire [M_SIZE-1:0] a_mm, b_mm, m_mm;
    wire [M_SIZE+1:0] m_n_mm;
    wire [RADIX+SIZE_LOG+1:0] m_prime_mm;
    //wire empty, busy;
    
    assign num_out = mm_info_out[7:4];
    
    wire [M_SIZE-1:0] data_f_table0, data_f_table1, data_f_table2, data_f_table3;
    wire rinc0, rinc1, rinc2, rinc3, rempty0, rempty1, rempty2, rempty3;
    wire scanning_e0, scanning_e1, scanning_e2, scanning_e3;
    wire en_pre_me0, en_pre_me1, en_pre_me2, en_pre_me3;
    wire [M_SIZE-1:0] e_0, e_1, e_2, e_3;
me_controller #(
    .M_SIZE(M_SIZE),
    .RADIX(RADIX),
    .SIZE_LOG(SIZE_LOG))   
    me_controller(
    .clk(clk),
    .rst_n(rst_n),
    .en_pre_me(en_pre_me),
    .en_me(en_me),
    .en_one_mm(en_one_mm),
    .num(num),
    
    .a(a),
    .e(e),
    .m(m),
    .m_n(m_n),
    .m_prime(m_prime),
        
    .mm_full(mm_full),
    .mm_busy(mm_busy),
    .mm_done(mm_done),
    .mm_flag(mm_flag),
    .mm_round(mm_round),

    .res(new_c),
    
    .mm_info_in(mm_info_out),
    .mm_info_out(mm_info_in),
    
    .z(z),
    .en_mm(en_mm),
    .a_mm(a_mm),
    .b_mm(b_mm),
    .m_mm(m_mm),
    .m_n_mm(m_n_mm),
    .m_prime_mm(m_prime_mm),
    
    
    .done(done),
    
    .data_f_table0(data_f_table0), .data_f_table1(data_f_table1), .data_f_table2(data_f_table2), .data_f_table3(data_f_table3),
    .rinc0(rinc0), .rinc1(rinc1), .rinc2(rinc2), .rinc3(rinc3),
    .rempty0(rempty0), .rempty1(rempty1), .rempty2(rempty2), .rempty3(rempty3),
    .scanning_e0(scanning_e0), .scanning_e1(scanning_e1), .scanning_e2(scanning_e2), .scanning_e3(scanning_e3),
    .en_pre_me0(en_pre_me0), .en_pre_me1(en_pre_me1), .en_pre_me2(en_pre_me2), .en_pre_me3(en_pre_me3),
    .e_0(e_0), .e_1(e_1), .e_2(e_2), .e_3(e_3)
);
    
pipelined_mm_top#(
    .M_SIZE(M_SIZE),
    .RADIX(RADIX),
    .SIZE_LOG(SIZE_LOG),
    .FIFO_DEPTH(FIFO_DEPTH),
    .FIFO_AddrWidth(FIFO_AddrWidth),
    .SIZE_ADD(SIZE_ADD)
)pipelined_mm_top(
    .clk(clk),
    .rst_n(rst_n),
    .en_mm(en_mm),
    .a(a_mm),
    .b(b_mm),
    .m(m_mm),
    .m_n(m_n_mm),
    .m_prime(m_prime_mm),
    .mm_info_in(mm_info_in),
    .mm_info_out(mm_info_out),
    .new_c(new_c),
    .mm_flag(mm_flag),
    .mm_round(mm_round),
    .mm_busy(mm_busy),
    .mm_full(mm_full),
    .mm_done(mm_done)
    );
    
/////////////////////// table manager ///////////////////////////////////    
table_manager#(
    .WIDTH(M_SIZE),
    .DEPTH(FIFO_DEPTH),
    .Width_addr(FIFO_AddrWidth),
    .URAM_ADDR(URAM_ADDR)
)table_manager_0(
    .clk(clk),
    .rst_n(rst_n),
    .en_pre_me(en_pre_me0),
    .e(e_0),
    .rinc(rinc0),
    .rdata(data_f_table0),
    .rempty(rempty0),
    .scanning_e(scanning_e0)
);

table_manager#(
    .WIDTH(M_SIZE),
    .DEPTH(FIFO_DEPTH),
    .Width_addr(FIFO_AddrWidth),
    .URAM_ADDR(URAM_ADDR)
)table_manager_1(
    .clk(clk),
    .rst_n(rst_n),
    .en_pre_me(en_pre_me1),
    .e(e_1),
    .rinc(rinc1),
    .rdata(data_f_table1),
    .rempty(rempty1),
    .scanning_e(scanning_e1)
);

table_manager#(
    .WIDTH(M_SIZE),
    .DEPTH(FIFO_DEPTH),
    .Width_addr(FIFO_AddrWidth),
    .URAM_ADDR(URAM_ADDR)
)table_manager_2(
    .clk(clk),
    .rst_n(rst_n),
    .en_pre_me(en_pre_me2),
    .e(e_2),
    .rinc(rinc2),
    .rdata(data_f_table2),
    .rempty(rempty2),
    .scanning_e(scanning_e2)
);
    
table_manager#(
    .WIDTH(M_SIZE),
    .DEPTH(FIFO_DEPTH),
    .Width_addr(FIFO_AddrWidth),
    .URAM_ADDR(URAM_ADDR)
)table_manager_3(
    .clk(clk),
    .rst_n(rst_n),
    .en_pre_me(en_pre_me3),
    .e(e_3),
    .rinc(rinc3),
    .rdata(data_f_table3),
    .rempty(rempty3),
    .scanning_e(scanning_e3)
);


endmodule

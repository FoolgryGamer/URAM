`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/24 18:45:24
// Design Name: 
// Module Name: pipelined_mm_top
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


module pipelined_mm_top#(
    parameter M_SIZE = 3072,
    parameter RADIX = 72,
    parameter SIZE_LOG = 6,
    parameter FIFO_DEPTH = 4,
    parameter FIFO_AddrWidth = 3,
    parameter SIZE_ADD = 128*25
)(
    input clk,
    input rst_n,
    input en_mm,
    input [M_SIZE-1:0] a,
    input [M_SIZE-1:0] b,
    input [M_SIZE-1:0] m,
    input [M_SIZE+1:0] m_n,
    input [RADIX+SIZE_LOG+1:0] m_prime,
    input [7:0] mm_info_in,
    output [7:0] mm_info_out,
    output [M_SIZE-1:0] new_c,
    output [3:0] mm_flag,
    output [4:0] mm_round,
    output mm_busy,
    output mm_full,
    output mm_done
    );
    wire [M_SIZE-1:0] last_a;
    wire [M_SIZE+RADIX+SIZE_LOG-1:0] last_c; 
    wire en_out_a, en_out_c;
    wire [M_SIZE-1:0]  now_a;
    wire [M_SIZE+RADIX+SIZE_LOG-1:0]  now_a_to_QR, now_c;
    wire [RADIX-1:0] now_bi;
    wire en_a, en_c;
    wire if_last;
    wire [1:0] stage_num_in, stage_num_out; 
    
    wire [2:0] cnt_4;
    
    wire [2:0] cnt_3;
    
    wire [7:0] mm_info_out_inner;
        
    assign new_c = now_c;
pipelined_mm
 #(
    .M_SIZE(M_SIZE),
    .SIZE_LOG(SIZE_LOG),
    .RADIX(RADIX)
)   
    pipelined_mm(
    .clk(clk),
    .rst_n(rst_n),
    .en(en_mm),
    
    .last_z(last_c),
    .last_a({78'd0,last_a}),
    .a(a),
    .b(b),
    .m(m),
    .m_n(m_n),
    .m_prime(m_prime),
    .en_out_a(en_out_a),
    .en_out_z(en_out_c),
    
    .now_z(now_c),
    .now_a(now_a),
    .now_a_to_QR(now_a_to_QR),
    .now_bi(now_bi),
    .en_z(en_c),
    .en_a(en_a),
    .if_last(if_last),
    
    .stage_num_in(stage_num_out),
    .mm_info_in(mm_info_out),
    .mm_info_ini_in(mm_info_in),
    .mm_info_out(mm_info_out_inner),
    
    .flag(mm_flag),
    .stage_num_out(stage_num_in),
    .round(mm_round),
    .busy(mm_busy),
    .full(mm_full),
    .done(mm_done)
);

phase_a#(
    .Size(M_SIZE), 
    .radix(RADIX), 
    .Size_log(SIZE_LOG), 
    .Size_add(SIZE_ADD))
    phase_a(
    .clk(clk),
    .rst_n(rst_n),
    .a(now_a_to_QR),
    .m(m),
    .m_n(m_n),
    .m_prime(m_prime),
    .en(en_a),
    .if_last(if_last),
    
    .new_a(last_a),
    .cnt_4(cnt_4),
    .en_out(en_out_a)
);

phase_c#(
    .Size(M_SIZE), 
    .radix(RADIX), 
    .Size_log(SIZE_LOG), 
    .Size_add(SIZE_ADD))
    phase_c(
    .clk(clk),
    .rst_n(rst_n),
    .c(now_c),
    .a(now_a),
    .bi(now_bi),
    .en(en_c),
    
    .new_c(last_c),
    .cnt_3(cnt_3),
    .en_out(en_out_c)
);

stage_num_counter stage_num_counter(
    .clk(clk),
    .rst_n(rst_n),
    .stage_num_in(stage_num_in),
    .en_a(en_a),
    .en_c(en_c),
    .en_out_a(en_out_a),
    .en_out_c(en_out_c),
    .cnt_4(cnt_4),
    .cnt_3(cnt_3),
    .mm_info_in(mm_info_out_inner),
    .mm_info_out(mm_info_out),
    .stage_num_out(stage_num_out)
    );
endmodule

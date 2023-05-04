module me#(
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
    input en_pre_me_top,
    input en_me_top,
    input en_one_mm_top,
    input [3:0] num,
    
    input [M_SIZE-1:0] a,
    input [M_SIZE-1:0] e,
    input [M_SIZE-1:0] m,
    input [M_SIZE+1:0] m_n,
    input [RADIX+SIZE_LOG+1:0] m_prime,
    
    output [M_SIZE-1:0] z,
    output [3:0] num_out,
    output done_top
);

// en_pre_me_top,en_me_top,en_one_mm_top signal change
reg convert_en_pre_me_top,convert_en_me_top,convert_en_one_mm_top;

always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)	begin
        convert_en_pre_me_top <= 0;
        convert_en_me_top <= 0;
        convert_en_one_mm_top <= 0;
    end
    else begin
        convert_en_pre_me_top <= en_pre_me_top;
        convert_en_me_top <= en_me_top;
        convert_en_one_mm_top <= en_one_mm_top;
    end
end

assign en_pre_me = !convert_en_pre_me_top && en_pre_me_top;
assign en_me = !convert_en_me_top && en_me_top;
assign en_one_mm = !convert_en_one_mm_top && en_one_mm_top;
// assign en_pre_me = ( (!convert_en_pre_me_top && en_pre_me_top) || (convert_en_pre_me_top && !en_pre_me_top)) ? 1 : 0;
// assign en_me = ( (!convert_en_me_top && en_me_top) || (convert_en_me_top && !en_me_top)) ? 1 : 0;
// assign en_one_mm = ( (!convert_en_one_mm_top && en_one_mm_top) || (convert_en_one_mm_top && !en_one_mm_top)) ? 1 : 0;

// done signal change
reg	convert_done;
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)	convert_done <= 0;
		else	convert_done <= (done) ? ~convert_done : convert_done;
end
assign done_top = convert_done;

me_top#(
    .M_SIZE(M_SIZE),
    .RADIX(RADIX),
    .SIZE_LOG(SIZE_LOG),
    .FIFO_DEPTH(FIFO_DEPTH),
    .FIFO_AddrWidth(FIFO_AddrWidth),
    .SIZE_ADD(SIZE_ADD),
    .URAM_ADDR(URAM_ADDR)
)   inst_me_top(
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
    .z(z),
    .num_out(num_out),
    .done(done)
    );
endmodule
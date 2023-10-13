module test_multi
(
	input [26:0] a,
	input [17:0] b,
    input clk,
    output [44:0] out
);

    dsp_macro_0 inst_dsp_0(
        .CLK(clk),
        .A(a),
        .B(b),
        .P(out));



endmodule
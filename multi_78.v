module multi
#(parameter radix = 78)
(
	input [radix-1:0] a,
	input [radix-1:0] b,
    input clk,
	output reg [45:0] res_0,
	output reg [45:0] res_1,
	output reg [45:0] res_2,
	output reg [45:0] res_3,
	output reg [45:0] res_4,
	output reg [45:0] res_5,
    output reg [45:0] res_6,
	output reg [45:0] res_7,
	output reg [45:0] res_8,
	output reg [45:0] res_9,
	output reg [45:0] res_10,
	output reg [45:0] res_11
    // output [42:0] res_12,
	// output [42:0] res_13,
	// output [42:0] res_14
);
    
    // this part needs to be changed based on the radix
	wire [25:0] wire_a [2:0];
	wire [19:0] wire_b [3:0];
    // wire [44:0] result [14:0];
	assign wire_a[0] = a[25:0];
	assign wire_a[1] = a[51:26];
    assign wire_a[2] = a[77:52];
	assign wire_b[0] = b[19:0];
	assign wire_b[1] = b[39:20];
	assign wire_b[2] = b[59:40];
    assign wire_b[3] = {2'b0,b[77:60]};

    /***************************************/
    // assign res_0 = result[0][42:0];
    // assign res_1 = result[1][42:0];
    // assign res_2 = result[2][42:0];
    // assign res_3 = result[3][42:0];
    // assign res_4 = result[4][42:0];
    // assign res_5 = result[5][42:0];
    // assign res_6 = result[6][42:0];
    // assign res_7 = result[7][42:0];
    // assign res_8 = result[8][42:0];
    // assign res_9 = result[9][42:0];
    // assign res_10 = result[10][42:0];
    // assign res_11 = result[11][42:0];
    // assign res_12 = result[12][42:0];
    // assign res_13 = result[13][42:0];
    // assign res_14 = result[14][42:0];

    // genvar i;
    // generate
    //     for(i=0;i<5;i=i+1) begin: dsp_generate
    //         dsp_macro_0 inst_dsp_0(
    //             .CLK(clk),
    //             .A({1'b0,wire_a[0]}),
    //             .B({1'b0,wire_b[i]}),
    //             .P({result[i]}));

    //         dsp_macro_0 inst_dsp_1(
    //             .CLK(clk),
    //             .A({1'b0,wire_a[1]}),
    //             .B({1'b0,wire_b[i]}),
    //             .P({result[i+5]}));

    //         dsp_macro_0 inst_dsp_2(
    //             .CLK(clk),
    //             .A({1'b0,wire_a[2]}),
    //             .B({1'b0,wire_b[i]}),
    //             .P({result[i+10]}));
    //     end
    // endgenerate

	// original code(DSP slice usage is not well-scheduled)
always @(posedge clk) begin
    res_0 <= wire_a[0]*wire_b[0];
    res_1 <= wire_a[0]*wire_b[1];
    res_2 <= wire_a[0]*wire_b[2];
    res_3 <= wire_a[0]*wire_b[3];
    res_4 <= wire_a[1]*wire_b[0];
    res_5 <= wire_a[1]*wire_b[1];
    res_6 <= wire_a[1]*wire_b[2];
    res_7 <= wire_a[1]*wire_b[3];
    res_8 <= wire_a[2]*wire_b[0];
    res_9 <= wire_a[2]*wire_b[1];
    res_10 <= wire_a[2]*wire_b[2];
    res_11 <= wire_a[2]*wire_b[3];
end
    // assign res_0 = wire_a[0]*wire_b[0];
    // assign res_1 = wire_a[0]*wire_b[1];
    // assign res_2 = wire_a[0]*wire_b[2];
    // assign res_3 = wire_a[0]*wire_b[3];
    // assign res_4 = wire_a[0]*wire_b[4];
    // assign res_4 = wire_a[1]*wire_b[0];
    // assign res_5 = wire_a[1]*wire_b[1];
    // assign res_6 = wire_a[1]*wire_b[2];
    // assign res_7 = wire_a[1]*wire_b[3];
    // assign res_9 = wire_a[1]*wire_b[4];
    // assign res_8 = wire_a[2]*wire_b[0];
    // assign res_9 = wire_a[2]*wire_b[1];
    // assign res_10 = wire_a[2]*wire_b[2];
    // assign res_11 = wire_a[2]*wire_b[3];
    // assign res_14 = wire_a[2]*wire_b[4];

endmodule
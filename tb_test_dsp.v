`timescale 1ns / 1ps

module tb;

reg [26:0] a;
reg [17:0] b;
reg clk;
wire [44:0] out;

test_multi inst(
    .a(a),
    .b(b),
    .clk(clk),
    .out(out)
);

always begin
    #10 clk = ~clk;
end

initial begin
    #0 clk = 0;
    a = 0;
    b = 0;
    #100 a = 27'h7ffffff;
    b = 18'h3ffff;
    #100
    a = 27'h3ffffff;
    b = 18'h1ffff;
    #100
    a = 27'h3ffffff;
    b = 18'h3ffff;
    #100
    a = 27'h7ffffff;
    b = 18'h1ffff;
    #1000 $finish;
end

endmodule
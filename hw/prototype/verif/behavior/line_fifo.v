`timescale 1ns/1ps

module line_fifo (
	RST,
	WR_CLK,
	DIN,
	WR_EN,
	FULL,
	OVERFLOW,
	RD_CLK,
	DOUT,
	RD_EN,
	EMPTY,
	UNDERFLOW
);
input        RST;
input        WR_CLK;
input [7:0]  DIN;
input        WR_EN;
output       FULL;
output       OVERFLOW;
input        RD_CLK;
output [7:0] DOUT;
input        RD_EN;
output       EMPTY;
output       UNDERFLOW;
endmodule


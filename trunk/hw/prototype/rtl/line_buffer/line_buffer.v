`timescale 1ns/1ps
`define    D  1

module line_buffer (
	writeClk,
	writeRst_n,
	VSYNC,
	HREF,
	DATA,
	readClk,
	readRst_n,
	linebuf_MCmd,
	linebuf_MAddr,
	linebuf_MData,
	linebuf_SCmdAccept,
	linebuf_SData,
	linebuf_SResp
);
input        writeClk;
input        writeRst_n;
input        VSYNC;
input        HREF;
input  [7:0] DATA;
input        readClk;
input        readRst_n;
input  [2:0] linebuf_MCmd;
input  [7:0] linebuf_MAddr;
input  [7:0] linebuf_MData;
output       linebuf_SCmdAccept;
output [7:0] linebuf_SData;
output [1:0] linebuf_SResp;

endmodule


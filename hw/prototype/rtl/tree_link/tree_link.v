`timescale 1ns/1ps

module tree_link (
	clk, rst_n,
	uart_MCmd, uart_MAddr, uart_MData, uart_SCmdAccept, 
	uart_SData, uart_SResp, uart_MRespAccept,
	linebuf_MCmd, linebuf_MAddr, linebuf_MData, linebuf_SCmdAccept,
	linebuf_SData, linebuf_SResp, linebuf_MRespAccept,
	clkrst_MCmd, clkrst_MAddr, clkrst_MData, clkrst_SCmdAccept,
	clkrst_SData, clkrst_SResp, clkrst_MRespAccept,
	debugger_MCmd, debugger_MAddr, debugger_MData, debugger_SCmdAccept,
	debugger_SData, debugger_SResp, debugger_MRespAccept,
	active_link, link_state
);

// 50MHz link
input clk;
input rst_n;

// uart Master interface
input  [2:0] uart_MCmd;
input  [7:0] uart_MAddr;
input  [7:0] uart_MData;
output       uart_SCmdAccept;
output [7:0] uart_SData;
output [1:0] uart_SResp;
input        uart_MRespAccept;

// linebuffer Slave interface
output [2:0] linebuf_MCmd;
output [7:0] linebuf_MAddr;
output [7:0] linebuf_MData;
input        linebuf_SCmdAccept;
input  [7:0] linebuf_SData;
input  [1:0] linebuf_SResp;
output       linebuf_MRespAccept;

// clock & reset Slave interface
output [2:0] clkrst_MCmd;
output [7:0] clkrst_MAddr;
output [7:0] clkrst_MData;
input        clkrst_SCmdAccept;
input  [7:0] clkrst_SData;
input  [1:0] clkrst_SResp;
output       clkrst_MRespAccept;

// debugger Slave interface
output [2:0] debugger_MCmd;
output [7:0] debugger_MAddr;
output [7:0] debugger_MData;
input        debugger_SCmdAccept;
input  [7:0] debugger_SData;
input  [1:0] debugger_SResp;
output       debugger_MRespAccept;

/* 
* Active Link monitor for debug 
*   2'b00 : idle
*   2'b01 : uart to linebuffer
*   2'b10 : uart to clock reset
*   2'b11 : uart to debugger
*/
output [1:0] active_link;

/* 
* Link State monitor for debug 
*   2'b00 : idle
*   2'b01 : Command handshake
*   2'b10 : Wait Response
*   2'b11 : Response handshake
*/
output [1:0] link_state;

endmodule


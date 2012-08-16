`timescale 1ns/1ps

module tree_link (
	clk, rst_n,
	uart_MCmd, uart_MAddr, uart_MData, uart_SCmdAccept, 
	uart_SData, uart_SResp, 
	linebuf_MCmd, linebuf_MAddr, linebuf_MData, linebuf_SCmdAccept,
	linebuf_SData, linebuf_SResp, 
	debugger_MCmd, debugger_MAddr, debugger_MData, debugger_SCmdAccept,
	debugger_SData, debugger_SResp, 
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

// linebuffer Slave interface
output [2:0] linebuf_MCmd;
output [7:0] linebuf_MAddr;
output [7:0] linebuf_MData;
input        linebuf_SCmdAccept;
input  [7:0] linebuf_SData;
input  [1:0] linebuf_SResp;

// debugger Slave interface
output [2:0] debugger_MCmd;
output [7:0] debugger_MAddr;
output [7:0] debugger_MData;
input        debugger_SCmdAccept;
input  [7:0] debugger_SData;
input  [1:0] debugger_SResp;

/* 
* Active Link monitor for debug 
*   2'b00 : idle
*   2'b01 : uart to linebuffer
*   2'b10 : uart to debugger
*   2'b11 : none
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


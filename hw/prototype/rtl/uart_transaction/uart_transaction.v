`timescale 1ns/1ps

module uart_transaction (
	clk,
	reset_n,
	RXD1,
	TXD1,
	uart_MCmd,
	uart_MAddr,
	uart_MData,
	uart_SCmdAccept,
	uart_SData,
	uart_SResp,
	uart_active_n,
);

input        clk;
input        reset_n;
input        RXD1;
output       TXD1;
output [2:0] uart_MCmd;
output [7:0] uart_MAddr;
output [7:0] uart_MData;
input        uart_SCmdAccept;
input  [7:0] uart_SData;
input  [1:0] uart_SResp;
output       uart_active_n;

endmodule


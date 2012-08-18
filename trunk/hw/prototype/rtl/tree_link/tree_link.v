`timescale 1ns/1ps
`define D 1

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

/*************************************** 
* Active Link monitor for debug 
*   2'b00 : no link
*   2'b01 : reserved for address hole
*   2'b10 : uart to linebuffer
*   2'b11 : uart to debugger
***************************************/
output [1:0] active_link;
parameter P_LINK_NONE    = 2'b00;
parameter P_LINK_HOLE    = 2'b01;
parameter P_LINK_LINEBUF = 2'b10;
parameter P_LINK_DEBUG   = 2'b11;

/*************************************** 
* Link State monitor for debug 
*   2'b00 : idle
*   2'b01 : Command handshake
*   2'b10 : Wait Response
*   2'b11 : undefined 
***************************************/
output [1:0] link_state;
parameter P_STATE_IDLE       = 2'b00;
parameter P_STATE_CMD_ACCEPT = 2'b01;
parameter P_STATE_WAIT_RESP  = 2'b10;

// this link accepts WR and RD (else dead lock)
wire   w_cmd_write;
wire   w_cmd_read;
assign w_cmd_write = (uart_MCmd == 3'b001);
assign w_cmd_read  = (uart_MCmd == 3'b010);

// 0x00-0x7F : line_buffer
// 0x80-0xFF : debugger
wire   [1:0] w_selected_target;
assign w_selected_target = route_by_address(uart_MAddr);

function [1:0] route_by_address;
	input [7:0] addr;
	casez(addr)
	8'b0zzzzzzz : route_by_address = P_LINK_LINEBUF;
	8'b1zzzzzzz : route_by_address = P_LINK_DEBUG;
	default     : route_by_address = P_LINK_HOLE;
	endcase
endfunction

// main state machine
reg  [2:0] r_active_link;
reg  [1:0] r_link_state;
reg  [2:0] r_MCmd;
reg  [7:0] r_MAddr;
reg  [7:0] r_MData;
reg        r_SCmdAccept;
reg  [1:0] r_SResp;
reg  [7:0] r_SData;
wire       w_slv_SCmdAccept;
wire [1:0] w_slv_SResp;
wire [7:0] w_slv_SData;

always @ (posedge clk or negedge rst_n)
	if(~rst_n) begin
		r_link_state  <= #`D P_STATE_IDLE;
		r_active_link <= #`D P_LINK_NONE;
		r_MCmd        <= #`D 3'b000;
		r_MAddr       <= #`D 8'h00;
		r_MData       <= #`D 8'h00;
		r_SCmdAccept  <= #`D 1'b1;
		r_SResp       <= #`D 2'b00;
		r_SData       <= #`D 8'h00;
	end else begin
		case(r_link_state)
		P_STATE_IDLE : begin
			if(w_cmd_write | w_cmd_read) begin
				r_link_state  <= #`D P_STATE_CMD_ACCEPT;
				r_active_link <= #`D w_selected_target;
				r_MCmd        <= #`D uart_MCmd;
				r_MAddr       <= #`D uart_MAddr;
				r_MData       <= #`D uart_MData;
				r_SCmdAccept  <= #`D 1'b0;
			end else begin
				r_active_link <= #`D P_LINK_NONE;
			end
			r_SResp <= 2'b00;
		end
		P_STATE_CMD_ACCEPT : begin
			if(w_slv_SCmdAccept) begin
				r_link_state  <= #`D P_STATE_WAIT_RESP;
				r_MCmd        <= #`D 3'b000;
			end
		end
		P_STATE_WAIT_RESP : begin
			if(|w_slv_SResp) begin
				r_link_state  <= #`D P_STATE_IDLE;
				r_SCmdAccept  <= #`D 1'b1;
				r_SResp       <= #`D w_slv_SResp;
				r_SData       <= #`D w_slv_SData;
			end
		end
		endcase
	end

// link status for debug monitor
assign active_link     = r_active_link;
assign link_state      = r_link_state;
// uart request path
assign uart_SCmdAccept = r_SCmdAccept;
// uart response path
assign uart_SResp      = r_SResp;
assign uart_SData      = r_SData;
// line buffer request path
assign linebuf_MCmd    = (r_active_link == P_LINK_LINEBUF) ? r_MCmd : 3'b000;
assign linebuf_MAddr   = r_MAddr;
assign linebuf_MData   = r_MData;
// debugger request path
assign linebuf_MCmd    = (r_active_link == P_LINK_DEBUG) ? r_MCmd : 3'b000;
assign debugger_MAddr  = r_MAddr;
assign debugger_MData  = r_MData;
// merged slave response path
assign w_slv_SCmdAccept = sel_SCmdAccept(r_active_link, linebuf_SCmdAccept, debugger_SCmdAccept);
assign w_slv_SResp      = sel_SResp(r_active_link, linebuf_SResp, debugger_SResp);
assign w_slv_SData      = sel_SData(r_active_link, linebuf_SData, debugger_SData);

function sel_SCmdAccept;
	input [1:0] link;
	input       SCmdAccept_lb;
	input       SCmdAccept_db;
	case(link)
	P_LINK_NONE    : sel_SCmdAccept = 1'b0;
	P_LINK_HOLE    : sel_SCmdAccept = 1'b1;
	P_LINK_LINEBUF : sel_SCmdAccept = SCmdAccept_lb;
	P_LINK_DEBUG   : sel_SCmdAccept = SCmdAccept_db;
	default        : sel_SCmdAccept = 1'bx;
	endcase
endfunction

function [1:0] sel_SResp;
	input [1:0] link;
	input [1:0] SResp_lb;
	input [1:0] SResp_db;
	case(link)
	P_LINK_NONE    : sel_SResp = 2'b00;
	P_LINK_HOLE    : sel_SResp = 2'b01;
	P_LINK_LINEBUF : sel_SResp = SResp_lb;
	P_LINK_DEBUG   : sel_SResp = SResp_db;
	default        : sel_SResp = 2'bx;
	endcase
endfunction

function [7:0] sel_SData;
	input [1:0] link;
	input [7:0] SData_lb;
	input [7:0] SData_db;
	case(link)
	P_LINK_NONE    : sel_SData = 8'h00;
	P_LINK_HOLE    : sel_SData = 8'h00;
	P_LINK_LINEBUF : sel_SData = SData_lb;
	P_LINK_DEBUG   : sel_SData = SData_db;
	default        : sel_SData = 8'hx;
	endcase
endfunction

endmodule


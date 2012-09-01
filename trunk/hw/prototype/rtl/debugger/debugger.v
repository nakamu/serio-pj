`timescale 1ns/1ps
`define D 1

module debugger (
	clk,
	reset_n,
	debugger_MCmd,
	debugger_MAddr,
	debugger_MData,
	debugger_SCmdAccept,
	debugger_SData,
	debugger_SResp,
	active_link,
	link_state,
	pushsw1,
	pushsw2,
	pushsw3,
	pushsw4,
	Seg1_A,
	Seg1_B,
	Seg1_C,
	Seg1_D,
	Seg1_E,
	Seg1_F,
	Seg1_G,
	Seg1_DP,
	Seg2_A,
	Seg2_B,
	Seg2_C,
	Seg2_D,
	Seg2_E,
	Seg2_F,
	Seg2_G,
	Seg2_DP
);
input        clk;
input        reset_n;

input  [2:0] debugger_MCmd;
input  [7:0] debugger_MAddr;
input  [7:0] debugger_MData;
output       debugger_SCmdAccept;
output [7:0] debugger_SData;
output [1:0] debugger_SResp;

input  [1:0] active_link;
input  [1:0] link_state;

input        pushsw1;
input        pushsw2;
input        pushsw3;
input        pushsw4;

output       Seg1_A;
output       Seg1_B;
output       Seg1_C;
output       Seg1_D;
output       Seg1_E;
output       Seg1_F;
output       Seg1_G;
output       Seg1_DP;
output       Seg2_A;
output       Seg2_B;
output       Seg2_C;
output       Seg2_D;
output       Seg2_E;
output       Seg2_F;
output       Seg2_G;
output       Seg2_DP;

/****************************
*         switch box        *
****************************/
wire   w_sw_pushing;
wire   w_pushed1;
wire   w_pushed2;
wire   w_pushed3;
wire   w_pushed4;
switch_box switch_box(
	.clk(clk), 
	.reset_n(reset_n),
	.sw1(pushsw1),
	.sw2(pushsw2),
	.sw3(pushsw3),
	.sw4(pushsw4),
	.edge1(w_pushed1),
	.edge2(w_pushed2),
	.edge3(w_pushed3),
	.edge4(w_pushed4),
	.pushing(w_sw_pushing)
);

/****************************
*     debug out selector    *
****************************/
reg [3:0] r_select1;
reg [3:0] r_select2;

always @ (posedge clk or negedge reset_n)
	if(~reset_n) begin
		r_select1 <= #`D 4'h0;
		r_select2 <= #`D 4'h0;
	end else begin
		if(w_pushed1)      r_select1 <= #`D r_select1 + 4'h1;
		else if(w_pushed2) r_select1 <= #`D r_select1 - 4'h1;
		if(w_pushed3)      r_select2 <= #`D r_select2 + 4'h1;
		else if(w_pushed4) r_select2 <= #`D r_select2 - 4'h1;
	end

reg [3:0] r_selected_out1;
reg [3:0] r_selected_out2;
reg [7:0] r_debug_reg1;
reg [7:0] r_debug_reg2;
reg [7:0] r_debug_reg3;
reg [7:0] r_debug_reg4;

always @ (posedge clk or negedge reset_n)
	if(~reset_n) begin
		r_selected_out1 <= #`D 4'h0;
		r_selected_out2 <= #`D 4'h0;
	end else begin
		r_selected_out1 <= #`D debug_selector(
			r_select1,
			{2'b00, active_link},  // 0
			{2'b00, link_state},   // 1
			4'b0000,               // 2 : reserved for line buffer
			4'b0000,               // 3 : reserved for line buffer
			4'b0000,               // 4 : reserved for line buffer
			4'b0000,               // 5 : reserved for line buffer
			4'b0000,               // 6 : reserved
			4'b0000,               // 7 : reserved
			r_debug_reg1[3:0],     // 8 : debug register
			r_debug_reg1[7:4],     // 9 : debug register
			r_debug_reg2[3:0],     // 10: debug register
			r_debug_reg2[7:4],     // 11: debug register
			r_debug_reg3[3:0],     // 12: debug register
			r_debug_reg3[7:4],     // 13: debug register
			r_debug_reg4[3:0],     // 14: debug register
			r_debug_reg4[7:4]      // 15: debug register
		);
		r_selected_out2 <= #`D debug_selector(
			r_select2,
			{2'b00, active_link},  // 0
			{2'b00, link_state},   // 1
			4'b0000,               // 2 : reserved for line buffer
			4'b0000,               // 3 : reserved for line buffer
			4'b0000,               // 4 : reserved for line buffer
			4'b0000,               // 5 : reserved for line buffer
			4'b0000,               // 6 : reserved
			4'b0000,               // 7 : reserved
			r_debug_reg1[3:0],     // 8 : debug register
			r_debug_reg1[7:4],     // 9 : debug register
			r_debug_reg2[3:0],     // 10: debug register
			r_debug_reg2[7:4],     // 11: debug register
			r_debug_reg3[3:0],     // 12: debug register
			r_debug_reg3[7:4],     // 13: debug register
			r_debug_reg4[3:0],     // 14: debug register
			r_debug_reg4[7:4]      // 15: debug register
		);
	end

function [3:0] debug_selector;
	input [3:0] sel;
	input [3:0] in0;
	input [3:0] in1;
	input [3:0] in2;
	input [3:0] in3;
	input [3:0] in4;
	input [3:0] in5;
	input [3:0] in6;
	input [3:0] in7;
	input [3:0] in8;
	input [3:0] in9;
	input [3:0] in10;
	input [3:0] in11;
	input [3:0] in12;
	input [3:0] in13;
	input [3:0] in14;
	input [3:0] in15;

	case(sel)
	4'h0 : debug_selector = in0;
	4'h1 : debug_selector = in1;
	4'h2 : debug_selector = in2;
	4'h3 : debug_selector = in3;
	4'h4 : debug_selector = in4;
	4'h5 : debug_selector = in5;
	4'h6 : debug_selector = in6;
	4'h7 : debug_selector = in7;
	4'h8 : debug_selector = in8;
	4'h9 : debug_selector = in9;
	4'ha : debug_selector = in10;
	4'hb : debug_selector = in11;
	4'hc : debug_selector = in12;
	4'hd : debug_selector = in13;
	4'he : debug_selector = in14;
	4'hf : debug_selector = in15;
	default : debug_selector = 8'hxx;
	endcase
endfunction

/****************************
*     7-Seg LED display     *
****************************/
wire [3:0] w_monitor_out1;
wire [3:0] w_monitor_out2;

assign w_monitor_out1 = w_sw_pushing ? r_select1 : r_selected_out1;
assign w_monitor_out2 = w_sw_pushing ? r_select2 : r_selected_out2;

assign {Seg1_DP, Seg1_G, Seg1_F, Seg1_E, Seg1_D, Seg1_C, Seg1_B, Seg1_A} = decode_7seg(w_monitor_out1);
assign {Seg2_DP, Seg2_G, Seg2_F, Seg2_E, Seg2_D, Seg2_C, Seg2_B, Seg2_A} = decode_7seg(w_monitor_out2);

function [7:0] decode_7seg;
	input [3:0] in;
	case(in)
		4'h0 : decode_7seg = 8'b11000000;
		4'h1 : decode_7seg = 8'b11111000;
		4'h2 : decode_7seg = 8'b10100100;
		4'h3 : decode_7seg = 8'b10110000;
		4'h4 : decode_7seg = 8'b10011001;
		4'h5 : decode_7seg = 8'b10010010;
		4'h6 : decode_7seg = 8'b10000010;
		4'h7 : decode_7seg = 8'b11111000;
		4'h8 : decode_7seg = 8'b10000000;
		4'h9 : decode_7seg = 8'b10010000;
		4'ha : decode_7seg = 8'b10001000;
		4'hb : decode_7seg = 8'b10000011;
		4'hc : decode_7seg = 8'b11110000;
		4'hd : decode_7seg = 8'b10100001;
		4'he : decode_7seg = 8'b10000110;
		4'hf : decode_7seg = 8'b10001110;
		default : decode_7seg = 8'hxx;
	endcase
endfunction

/****************************
*          bus I/F          *
****************************/

wire w_write_enable;
wire w_read_enable;
assign w_write_enable = (debugger_MCmd == 3'b001) ? 1'b1 : 1'b0;
assign w_read_enable  = (debugger_MCmd == 3'b010) ? 1'b1 : 1'b0;

reg r_read_enable;
always @ (posedge clk or negedge reset_n)
	if(~reset_n) r_read_enable <= #`D 2'b00;
	else         r_read_enable <= #`D w_read_enable;

// always receive request and return resp at 1 cycle
assign debugger_SCmdAccept = 1'b1;
assign debugger_SResp      = {1'b0, r_read_enable};

// read data
reg [7:0] debugger_SData;
always @ (posedge clk or negedge reset_n)
	if(~reset_n) begin
		debugger_SData <= #`D 8'h00;
	end else begin
		if(w_read_enable) begin
			case(debugger_MAddr[6:0])
				7'h00 : debugger_SData <= #`D 8'h44;
				7'h01 : debugger_SData <= #`D 8'h45;
				7'h02 : debugger_SData <= #`D 8'h41;
				7'h03 : debugger_SData <= #`D 8'h44;
				7'h04 : debugger_SData <= #`D 8'h42;
				7'h05 : debugger_SData <= #`D 8'h45;
				7'h06 : debugger_SData <= #`D 8'h45;
				7'h07 : debugger_SData <= #`D 8'h46;
				7'h10 : debugger_SData <= #`D r_debug_reg1;
				7'h11 : debugger_SData <= #`D r_debug_reg2;
				7'h12 : debugger_SData <= #`D r_debug_reg3;
				7'h13 : debugger_SData <= #`D r_debug_reg4;
				7'h20 : debugger_SData <= #`D {4'b0000, r_select1};
				7'h21 : debugger_SData <= #`D {4'b0000, r_select2};
				7'h22 : debugger_SData <= #`D {4'b0000, r_selected_out1};
				7'h23 : debugger_SData <= #`D {4'b0000, r_selected_out2};
				7'h30 : debugger_SData <= #`D {2'b00, link_state, 2'b00, active_link};
				default : debugger_SData <= #`D 8'h00;
			endcase
		end
	end

// write data
wire w_write_enable_debug_reg1; 
wire w_write_enable_debug_reg2; 
wire w_write_enable_debug_reg3; 
wire w_write_enable_debug_reg4; 
assign w_write_enable_debug_reg1 = w_write_enable & (debugger_MAddr[6:0] == 7'h10);
assign w_write_enable_debug_reg2 = w_write_enable & (debugger_MAddr[6:0] == 7'h11);
assign w_write_enable_debug_reg3 = w_write_enable & (debugger_MAddr[6:0] == 7'h12);
assign w_write_enable_debug_reg4 = w_write_enable & (debugger_MAddr[6:0] == 7'h13);

always @ (posedge clk or negedge reset_n)
	if(~reset_n) r_debug_reg1 <= #`D 8'h00;
	else         r_debug_reg1 <= #`D w_write_enable_debug_reg1 ? debugger_MData : r_debug_reg1;

always @ (posedge clk or negedge reset_n)
	if(~reset_n) r_debug_reg2 <= #`D 8'h00;
	else         r_debug_reg2 <= #`D w_write_enable_debug_reg2 ? debugger_MData : r_debug_reg2;

always @ (posedge clk or negedge reset_n)
	if(~reset_n) r_debug_reg3 <= #`D 8'h00;
	else         r_debug_reg3 <= #`D w_write_enable_debug_reg3 ? debugger_MData : r_debug_reg3;

always @ (posedge clk or negedge reset_n)
	if(~reset_n) r_debug_reg4 <= #`D 8'h00;
	else         r_debug_reg4 <= #`D w_write_enable_debug_reg4 ? debugger_MData : r_debug_reg4;


endmodule


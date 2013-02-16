`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:43:27 02/16/2013 
// Design Name: 
// Module Name:    seg_ctrl 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module seg_ctrl(
    input clk,
    input reset_n,
    input [15:0] hex,
    output AN0,
    output AN1,
    output AN2,
    output AN3,
    output DP,
    output A,
    output B,
    output C,
    output D,
    output E,
    output F,
    output G
    );

assign DP = 1'b1;
reg [3:0] active;
assign AN0 = active[0];
assign AN1 = active[1];
assign AN2 = active[2];
assign AN3 = active[3];

reg [6:0] char0;
reg [6:0] char1;
reg [6:0] char2;
reg [6:0] char3;

assign A = ~AN0 ? char0[0] : ~AN1 ? char1[0] : ~AN2 ? char2[0] : ~AN3 ? char3[0] : 1'b1;
assign B = ~AN0 ? char0[1] : ~AN1 ? char1[1] : ~AN2 ? char2[1] : ~AN3 ? char3[1] : 1'b1;
assign C = ~AN0 ? char0[2] : ~AN1 ? char1[2] : ~AN2 ? char2[2] : ~AN3 ? char3[2] : 1'b1;
assign D = ~AN0 ? char0[3] : ~AN1 ? char1[3] : ~AN2 ? char2[3] : ~AN3 ? char3[3] : 1'b1;
assign E = ~AN0 ? char0[4] : ~AN1 ? char1[4] : ~AN2 ? char2[4] : ~AN3 ? char3[4] : 1'b1;
assign F = ~AN0 ? char0[5] : ~AN1 ? char1[5] : ~AN2 ? char2[5] : ~AN3 ? char3[5] : 1'b1;
assign G = ~AN0 ? char0[6] : ~AN1 ? char1[6] : ~AN2 ? char2[6] : ~AN3 ? char3[6] : 1'b1;

wire update;
parameter P_CNT_THRES = 8'hff;
reg [7:0] count;

always @ (posedge clk or negedge reset_n)
	if(~reset_n) begin
		count <= 8'h00;
	end else begin
		count <= (count == P_CNT_THRES) ? 8'h00 : count + 8'h1;
	end

assign update = count == P_CNT_THRES;

always @ (posedge clk or negedge reset_n)
	if(~reset_n) begin
		active <= 4'b1110;
	end else begin
		if(update) active <= {active[0], active[3:1]};
	end

function [6:0] val2seg;
input [3:0] val;
case(val)
	4'h0 : val2seg = 7'b1000000;
	4'h1 : val2seg = 7'b1111001;
	4'h2 : val2seg = 7'b0100100;
	4'h3 : val2seg = 7'b0110000;
	4'h4 : val2seg = 7'b0011001;
	4'h5 : val2seg = 7'b0010010;
	4'h6 : val2seg = 7'b0000010;
	4'h7 : val2seg = 7'b1111000;
	4'h8 : val2seg = 7'b0000000;
	4'h9 : val2seg = 7'b0010000;
	4'ha : val2seg = 7'b0001000;
	4'hb : val2seg = 7'b0000011;
	4'hc : val2seg = 7'b1000110;
	4'hd : val2seg = 7'b0100001;
	4'he : val2seg = 7'b0000110;
	4'hf : val2seg = 7'b0001110;
	default : val2seg = 7'b1111111;
endcase
endfunction

always @ (posedge clk or negedge reset_n)
	if(~reset_n) begin
		char0 <= 7'b1111111;
		char1 <= 7'b1111111;
		char2 <= 7'b1111111;
		char3 <= 7'b1111111;		
	end else begin
		char0 <= val2seg(hex[3:0]);
		char1 <= val2seg(hex[7:4]);
		char2 <= val2seg(hex[11:8]);
		char3 <= val2seg(hex[15:12]);		
	end

endmodule

`timescale 1ns/1ps

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

endmodule


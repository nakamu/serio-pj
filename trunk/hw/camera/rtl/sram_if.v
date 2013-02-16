`timescale 1ns/1ns
`define D 1

module sram_if(
	source_sel,
	xonOE, xonWE, xopAddr,
	xonCE1, xonUB1, xonLB1, xbpDATA1,
	xonCE2, xonUB2, xonLB2, xbpDATA2,
	s0_OE, s0_WE, s0_Addr,
	s0_WD, s0_RD,
	s1_OE, s1_WE, s1_Addr,
	s1_WD, s1_RD
);

input         source_sel;

output        xonOE;
output        xonWE;
output [17:0] xopAddr;
output        xonCE1;
output        xonUB1;
output        xonLB1;
inout  [15:0] xbpDATA1;
output        xonCE2;
output        xonUB2;
output        xonLB2;
inout  [15:0] xbpDATA2;

input         s0_OE;
input         s0_WE;
input  [17:0] s0_Addr;
input  [31:0] s0_WD;
output [31:0] s0_RD;

input         s1_OE;
input         s1_WE;
input  [17:0] s1_Addr;
input  [31:0] s1_WD;
output [31:0] s1_RD;

// always active
assign xonCE1 = 1'b0;
assign xonUB1 = 1'b0;
assign xonLB1 = 1'b0;
assign xonCE2 = 1'b0;
assign xonUB2 = 1'b0;
assign xonLB2 = 1'b0;

assign xonOE   = source_sel ? s1_OE   : s0_OE;
assign xonWE   = source_sel ? s1_WE   : s0_WE;
assign xopAddr = source_sel ? s1_Addr : s0_Addr;
assign xbpDATA1 = (xonOE & ~xonWE) ? (source_sel ? s1_WD[15:0]  : s0_WD[15:0])  : 16'hz;
assign xbpDATA2 = (xonOE & ~xonWE) ? (source_sel ? s1_WD[31:16] : s0_WD[31:16]) : 16'hz;
//assign xbpDATA1 = (xonOE & ~xonWE) ? 16'hdead : 16'hz;
//assign xbpDATA2 = (xonOE & ~xonWE) ? 16'hbeaf : 16'hz;
assign s0_RD    = xonOE ? 32'h0 : {xbpDATA2, xbpDATA1};
assign s1_RD    = xonOE ? 32'h0 : {xbpDATA2, xbpDATA1};

endmodule

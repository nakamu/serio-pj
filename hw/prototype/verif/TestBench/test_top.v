`timescale 1ns/1ns

module test_top;
`define MCLK_HCYCLE 50
`define SIM_TIME    40000000

reg       xipMCLK;       // P83
reg       xipRESET;      // P85
wire      xopCAM_PWDN;   // P62 : vport1_3 
wire      xonCAM_RESET;  // P63 : vport1_4
wire      xopCAM_XCLK;   // P65 : vport1_5
reg       xipCAM_VSYNC;  // P66 : vport1_6
reg       xipCAM_HREF;   // P67 : vport1_7
reg       xipCAM_PCLK;   // P68 : vport1_8
reg [7:0] xipCAM_D;      // P33,34,35,36,40,41,57,58
reg       xipSW1;        // P22
reg       xipSW2;        // P23
reg       xipSW3;        // P24
reg       xipSW4;        // P26
wire      xopLED1;       // P54
wire      xopLED2;       // P53
wire      xop7Seg1_A;    // P91
wire      xop7Seg1_B;    // P92
wire      xop7Seg1_C;    // P12
wire      xop7Seg1_D;    // P15
wire      xop7Seg1_E;    // P16
wire      xop7Seg1_F;    // P90
wire      xop7Seg1_G;    // P86
wire      xop7Seg1_DP;   // P11
wire      xop7Seg2_A;    // P3
wire      xop7Seg2_B;    // P2
wire      xop7Seg2_C;    // P5
wire      xop7Seg2_D;    // P9
wire      xop7Seg2_E;    // P10
wire      xop7Seg2_F;    // P95
wire      xop7Seg2_G;    // P94
wire      xop7Seg2_DP;   // P4
wire      xopTXD;        // P60 : vport1_1
reg       xipRXD;        // P61 : vport1_2

top top(
	.xipMCLK      ( xipMCLK ),
	.xipRESET     ( xipRESET ),
	.xopCAM_PWDN  ( xopCAM_PWDN ),
	.xipCAM_VSYNC ( xipCAM_VSYNC ),
	.xipCAM_HREF  ( xipCAM_HREF ),
	.xipCAM_PCLK  ( xipCAM_PCLK ),
	.xopCAM_XCLK  ( xopCAM_XCLK ),
	.xonCAM_RESET ( xonCAM_RESET ),
	.xipCAM_D     ( xipCAM_D ),
	.xopTXD       ( xopTXD ),
	.xipRXD       ( xipRXD ),
	.xipSW1       ( xipSW1 ),
	.xipSW2       ( xipSW2 ),
	.xipSW3       ( xipSW3 ),
	.xipSW4       ( xipSW4 ),
	.xopLED1      ( xopLED1 ),
	.xopLED2      ( xopLED2 ),
	.xop7Seg1_A   ( xop7Seg1_A ),
	.xop7Seg1_B   ( xop7Seg1_B ),
	.xop7Seg1_C   ( xop7Seg1_C ),
	.xop7Seg1_D   ( xop7Seg1_D ),
	.xop7Seg1_E   ( xop7Seg1_E ),
	.xop7Seg1_F   ( xop7Seg1_F ),
	.xop7Seg1_G   ( xop7Seg1_G ),
	.xop7Seg1_DP  ( xop7Seg1_DP ),
	.xop7Seg2_A   ( xop7Seg2_A ),
	.xop7Seg2_B   ( xop7Seg2_B ),
	.xop7Seg2_C   ( xop7Seg2_C ),
	.xop7Seg2_D   ( xop7Seg2_D ),
	.xop7Seg2_E   ( xop7Seg2_E ),
	.xop7Seg2_F   ( xop7Seg2_F ),
	.xop7Seg2_G   ( xop7Seg2_G ),
	.xop7Seg2_DP  ( xop7Seg2_DP )
);

/***** Main Sequence *****/
initial begin
	xipRXD = 1'b0;
	#`SIM_TIME $finish;
end

/***** Clock & Reset *****/
always begin
	xipMCLK = 0; #`MCLK_HCYCLE;
	xipMCLK = 1; #`MCLK_HCYCLE;
end

initial begin
	xipRESET = 1'b0; #100
	xipRESET = 1'b1; #100000
	xipRESET = 1'b0;
end

/***** Dump waveform *****/
initial begin
	$dumpfile("test_top.vcd");
	$dumpvars(0, top);
end

endmodule

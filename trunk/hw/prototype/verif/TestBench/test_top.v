`timescale 1ns/1ns

module test_top;
`define MCLK_HCYCLE 50
`define SIM_TIME    40000000

reg       xipMCLK;       // P83
reg       xinRESET;      // P85
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
wire      xonLED1;       // P54
wire      xonLED2;       // P53
wire      xon7Seg1_A;    // P91
wire      xon7Seg1_B;    // P92
wire      xon7Seg1_C;    // P12
wire      xon7Seg1_D;    // P15
wire      xon7Seg1_E;    // P16
wire      xon7Seg1_F;    // P90
wire      xon7Seg1_G;    // P86
wire      xon7Seg1_DP;   // P11
wire      xon7Seg2_A;    // P3
wire      xon7Seg2_B;    // P2
wire      xon7Seg2_C;    // P5
wire      xon7Seg2_D;    // P9
wire      xon7Seg2_E;    // P10
wire      xon7Seg2_F;    // P95
wire      xon7Seg2_G;    // P94
wire      xon7Seg2_DP;   // P4
wire      xopTXD;        // P60 : vport1_1
reg       xipRXD;        // P61 : vport1_2

top top(
	.xipMCLK      ( xipMCLK ),
	.xinRESET     ( xinRESET ),
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
	.xonLED1      ( xonLED1 ),
	.xonLED2      ( xonLED2 ),
	.xon7Seg1_A   ( xon7Seg1_A ),
	.xon7Seg1_B   ( xon7Seg1_B ),
	.xon7Seg1_C   ( xon7Seg1_C ),
	.xon7Seg1_D   ( xon7Seg1_D ),
	.xon7Seg1_E   ( xon7Seg1_E ),
	.xon7Seg1_F   ( xon7Seg1_F ),
	.xon7Seg1_G   ( xon7Seg1_G ),
	.xon7Seg1_DP  ( xon7Seg1_DP ),
	.xon7Seg2_A   ( xon7Seg2_A ),
	.xon7Seg2_B   ( xon7Seg2_B ),
	.xon7Seg2_C   ( xon7Seg2_C ),
	.xon7Seg2_D   ( xon7Seg2_D ),
	.xon7Seg2_E   ( xon7Seg2_E ),
	.xon7Seg2_F   ( xon7Seg2_F ),
	.xon7Seg2_G   ( xon7Seg2_G ),
	.xon7Seg2_DP  ( xon7Seg2_DP )
);

/***** Main Sequence *****/
initial begin
	xipRXD = 1'b0;
	xipSW1 = 1'b0;
	xipSW2 = 1'b0;
	xipSW3 = 1'b0;
	xipSW4 = 1'b0;
	#`SIM_TIME $finish;
end

/***** Clock & Reset *****/
always begin
	xipMCLK = 0; #`MCLK_HCYCLE;
	xipMCLK = 1; #`MCLK_HCYCLE;
end

initial begin
	xinRESET = 1'b1; #100
	xinRESET = 1'b0; #100000
	xinRESET = 1'b1;
end

/***** Dump waveform *****/
initial begin
	$dumpfile("test_top.vcd");
	$dumpvars(0, top);
end

endmodule

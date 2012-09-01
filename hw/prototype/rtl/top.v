`timescale 1ns/1ps

module top (
	xipMCLK,
	xinRESET,
	xopCAM_PWDN,
	xipCAM_VSYNC,
	xipCAM_HREF,
	xipCAM_PCLK,
	xopCAM_XCLK,
	xonCAM_RESET,
	xipCAM_D,
	xopTXD,
	xipRXD,
	xipSW1,
	xipSW2,
	xipSW3,
	xipSW4,
	xonLED1, 
	xonLED2, 
	xon7Seg1_A,
	xon7Seg1_B,
	xon7Seg1_C,
	xon7Seg1_D,
	xon7Seg1_E,
	xon7Seg1_F,
	xon7Seg1_G,
	xon7Seg1_DP,
	xon7Seg2_A,
	xon7Seg2_B,
	xon7Seg2_C,
	xon7Seg2_D,
	xon7Seg2_E,
	xon7Seg2_F,
	xon7Seg2_G,
	xon7Seg2_DP
);
// System IO
input       xipMCLK;     // P83
input       xinRESET;    // P85

// Camera IO
// input       xipCAM_STROBE; // open input (no use)
output      xopCAM_PWDN;   // P62 : vport1_3 
output      xonCAM_RESET;  // P63 : vport1_4
output      xopCAM_XCLK;   // P65 : vport1_5
input       xipCAM_VSYNC;  // P66 : vport1_6
input       xipCAM_HREF;   // P67 : vport1_7
input       xipCAM_PCLK;   // P68 : vport1_8
input [7:0] xipCAM_D;      // P33,34,35,36,40,41,57,58

// Switch
input       xipSW1;        // P22
input       xipSW2;        // P23
input       xipSW3;        // P24
input       xipSW4;        // P26

// LEDs
output      xonLED1;       // P54
output      xonLED2;       // P53

// 7-seg LEDs
output      xon7Seg1_A;    // P91
output      xon7Seg1_B;    // P92
output      xon7Seg1_C;    // P12
output      xon7Seg1_D;    // P15
output      xon7Seg1_E;    // P16
output      xon7Seg1_F;    // P90
output      xon7Seg1_G;    // P86
output      xon7Seg1_DP;   // P11
output      xon7Seg2_A;    // P3
output      xon7Seg2_B;    // P2
output      xon7Seg2_C;    // P5
output      xon7Seg2_D;    // P9
output      xon7Seg2_E;    // P10
output      xon7Seg2_F;    // P95
output      xon7Seg2_G;    // P94
output      xon7Seg2_DP;   // P4

// RS232C
output      xopTXD;        // P60 : vport1_1
input       xipRXD;        // P61 : vport1_2

assign xopCAM_PWDN = 1'b0;

wire w_mclk;
wire w_mreset_n;
wire w_pixelclk;
wire w_PReset_n;

clock_reset clock_reset(
	.refclk      ( xipMCLK ),
	.reset_n     ( xinRESET ),
	.mclk        ( w_mclk ),
	.mreset_n    ( w_mreset_n ),
	.cam_clk     ( xopCAM_XCLK ),
	.cam_reset_n ( xonCAM_RESET ),
	.pclk        ( xipCAM_PCLK ),
	.pixelclk    ( w_pixelclk ),
	.preset_n    ( w_PReset_n ),
	.pll_lock_n  ( xonLED1 )
);

wire [2:0] uart_MCmd;
wire [7:0] uart_MAddr;
wire [7:0] uart_MData;
wire       uart_SCmdAccept;
wire [7:0] uart_SData;
wire [1:0] uart_SResp;
wire [2:0] linebuf_MCmd;
wire [7:0] linebuf_MAddr;
wire [7:0] linebuf_MData;
wire       linebuf_SCmdAccept;
wire [7:0] linebuf_SData;
wire [1:0] linebuf_SResp;
wire [2:0] debugger_MCmd;
wire [7:0] debugger_MAddr;
wire [7:0] debugger_MData;
wire       debugger_SCmdAccept;
wire [7:0] debugger_SData;
wire [1:0] debugger_SResp;
wire [1:0] active_link;
wire [1:0] link_state;

tree_link tree_link(
	.clk                 ( w_mclk ),
	.rst_n               ( w_mreset_n ),
	.uart_MCmd           ( uart_MCmd ),
	.uart_MAddr          ( uart_MAddr ),
	.uart_MData          ( uart_MData ),
	.uart_SCmdAccept     ( uart_SCmdAccept ),
	.uart_SData          ( uart_SData ),
	.uart_SResp          ( uart_SResp ),
	.linebuf_MCmd        ( linebuf_MCmd ),
	.linebuf_MAddr       ( linebuf_MAddr ),
	.linebuf_MData       ( linebuf_MData ),
	.linebuf_SCmdAccept  ( linebuf_SCmdAccept ),
	.linebuf_SData       ( linebuf_SData ),
	.linebuf_SResp       ( linebuf_SResp ),
	.debugger_MCmd       ( debugger_MCmd ),
	.debugger_MAddr      ( debugger_MAddr ),
	.debugger_MData      ( debugger_MData ),
	.debugger_SCmdAccept ( debugger_SCmdAccept ),
	.debugger_SData      ( debugger_SData ),
	.debugger_SResp      ( debugger_SResp ),
	.active_link         ( active_link ),
	.link_state          ( link_state )
);

uart_transaction uart_transaction(
	.clk             ( w_mclk ),
	.reset_n         ( w_mreset_n ),
	.RXD1            ( xipRXD ),
	.TXD1            ( xopTXD ),
	.uart_MCmd       ( uart_MCmd ),
	.uart_MAddr      ( uart_MAddr ),
	.uart_MData      ( uart_MData ),
	.uart_SCmdAccept ( uart_SCmdAccept ),
	.uart_SData      ( uart_SData ),
	.uart_SResp      ( uart_SResp ),
	.uart_active_n   ( xonLED2 )
);

line_buffer line_buffer(
	.writeClk           ( w_pixelclk ),
	.writeRst_n         ( w_PReset_n ),
	.VSYNC              ( xipCAM_VSYNC ),
	.HREF               ( xipCAM_HREF ),
	.DATA               ( xipCAM_D ),
	.readClk            ( w_mclk ),
	.readRst_n          ( w_mreset_n ),
	.linebuf_MCmd       ( linebuf_MCmd ),
	.linebuf_MAddr      ( linebuf_MAddr ),
	.linebuf_MData      ( linebuf_MData ),
	.linebuf_SCmdAccept ( linebuf_SCmdAccept ),
	.linebuf_SData      ( linebuf_SData ),
	.linebuf_SResp      ( linebuf_SResp )
);

debugger debugger(
	.clk                 ( w_mclk ),
	.reset_n             ( w_mreset_n ),
	.debugger_MCmd       ( debugger_MCmd ),
	.debugger_MAddr      ( debugger_MAddr ),
	.debugger_MData      ( debugger_MData ),
	.debugger_SCmdAccept ( debugger_SCmdAccept ),
	.debugger_SData      ( debugger_SData ),
	.debugger_SResp      ( debugger_SResp ),
	.active_link         ( active_link ),
	.link_state          ( link_state ),
	.pushsw1             ( xipSW1 ),
	.pushsw2             ( xipSW2 ),
	.pushsw3             ( xipSW3 ),
	.pushsw4             ( xipSW4 ),
	.Seg1_A              ( xon7Seg1_A ),
	.Seg1_B              ( xon7Seg1_B ),
	.Seg1_C              ( xon7Seg1_C ),
	.Seg1_D              ( xon7Seg1_D ),
	.Seg1_E              ( xon7Seg1_E ),
	.Seg1_F              ( xon7Seg1_F ),
	.Seg1_G              ( xon7Seg1_G ),
	.Seg1_DP             ( xon7Seg1_DP ),
	.Seg2_A              ( xon7Seg2_A ),
	.Seg2_B              ( xon7Seg2_B ),
	.Seg2_C              ( xon7Seg2_C ),
	.Seg2_D              ( xon7Seg2_D ),
	.Seg2_E              ( xon7Seg2_E ),
	.Seg2_F              ( xon7Seg2_F ),
	.Seg2_G              ( xon7Seg2_G ),
	.Seg2_DP             ( xon7Seg2_DP )
);

endmodule


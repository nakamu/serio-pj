`timescale 1ns/1ps

module top (
	xipMCLK,
	xipRESET,
	xopCAM_PWDN,
	xipCAM_VSYNC,
	xipCAM_HREF,
	xipCAM_PCLK,
	xipCAM_STROBE,
	xopCAM_XCLK,
	xonCAM_RESET,
	xopCAM_SIO_C,
	xbpCAM_SIO_D,
	xipCAM_D,
	xopTXD,
	xipRXD,
	xopLD7, xopLD6, xopLD5, xopLD4, xopLD3, xopLD2, xopLD1, xopLD0,
);
// System IO
input       xipMCLK;     // T9
input       xipRESET;    // L14

// Camera IO
output      xopCAM_PWDN;
input       xipCAM_VSYNC;
input       xipCAM_HREF;
input       xipCAM_PCLK;
input       xipCAM_STROBE; // open input (no use)
output      xopCAM_XCLK;
output      xonCAM_RESET;
input [7:0] xipCAM_D;
//output      xopCAM_SIO_C;
//inout       xbpCAM_SIO_D;

// LEDs
output      xopLD7;    // P11
output      xopLD6;    // P12
output      xopLD5;    // N12
output      xopLD4;    // P13
output      xopLD3;    // N14
output      xopLD2;    // L12
output      xopLD1;    // P14
output      xopLD0;    // K12

// RS232C
output      xopTXD;    // R13
input       xipRXD;    // T13

wire w_RSClk;
wire w_RSReset_n;
wire w_SCCBClk;
wire w_SCCBReset_n;
wire w_CamClk;
wire w_CamReset_n;
wire w_PReset_n;

clock_reset clock_reset(
	.mclk         (xipMCLK),
	.reset_n      (~xipRESET),
	.rs_clk       (w_RSClk),
	.rs_reset_n   (w_RSReset_n),
	.sccb_clk     (w_SCCBClk),
	.sccb_reset_n (w_SCCBReset_n),
	.cam_clk      (w_CamClk),
	.cam_reset_n  (w_CamReset_n),
	.pclk         (xipCAM_PCLK),
	.preset_n     (w_PReset_n)
);

wire       w_frameStart;
wire       w_frameEnd;
wire       w_writeEn;
wire [7:0] w_writeData;
wire       w_readStart;
wire [7:0] w_readData;
wire       w_txStatus;

assign xopCAM_XCLK  = w_CamClk;
assign xonCAM_RESET = w_CamReset_n;

pixel_buffer pixel_buffer(
	.writeClk  (xipCAM_PCLK),
	.writeRst_n(w_PReset_n),
	.VSYNC     (xipCAM_VSYNC),
	.HREF      (xipCAM_HREF),
	.DATA      (xipCAM_D),
	.readClk   (w_RSClk),
	.readRst_n (w_RSReset_n),
	.readData  (w_readData),
	.txStatus  (w_txStatus),
	.txStart   (w_readStart)
);

uart_transaction uart_transaction(
	.pavsv01a2rsio_01aRSClk    (w_RSClk),
	.pavsv01a2rsio_01aReset_n  (w_RSReset_n),
	.swdec01a2rsio_01aTestMode (4'b0000), // tie 0
	.dbgif01a2rsio_01aTxBitRate(4'h7),    // tie const
	.dbgif01a2rsio_01aTxStart  (w_readStart),
	.dbgif01a2rsio_01aTxData   (w_readData),
	.rsio_01a2dbgif01aTxStatus (w_txStatus),
	.dbgif01a2rsio_01aRxBitRate(4'h7),    // tie const
	.dbgif01a2rsio_01aRxFetch  (1'b0),    // tie 0
	.rsio_01a2dbgif01aRxData   (),        // open
	.rsio_01a2dbgif01aRxStatus (),        // open
	.xipRXD1(xipRXD),
	.xopTXD1(xopTXD),
	.xipRXD2(1'b0),                       // tie 0
	.xopTXD2(1'b0)                        // tie 0
);

endmodule


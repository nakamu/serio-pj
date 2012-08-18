`define D 1
`timescale 1ns/1ns

module uart_io (
	RSClk,
	Reset_n,
	TestMode,
	TxBitRate,
	TxStart,
	TxData,
	TxStatus,
	RxBitRate,
	RxFetch,
	RxData,
	RxStatus,
	xipRXD1,
	xopTXD1,
	xipRXD2,
	xopTXD2
);

input         RSClk;
input         Reset_n;
input  [3:0]  TestMode;

input  [3:0]  TxBitRate;
input         TxStart;
input  [7:0]  TxData;
output        TxStatus;

input  [3:0]  RxBitRate;
input         RxFetch;
output [7:0]  RxData;
output [1:0]  RxStatus;

input         xipRXD1;
output        xopTXD1;
input         xipRXD2;
input         xopTXD2;

wire          w_TXD;
wire          w_TxData;

assign        xopTXD1 = w_TXD;
reg           r_divTxClk;

// TestMode Override
//   TestMode definition
//     4'b0000 : Normal   mode
//     4'b0001 : Loopback mode (xipRXD1 -> xopTXD1)
//     4'b0010 : Bypass   mode (xipRXD2 -> xopTXD1)
//     4'b0100 : Copy     mode (xopTXD2 -> xopTXD1)
//     4'b1000 : RS Clock mode
assign        w_TXD = TestMode[3] ? r_divTxClk : 
                      TestMode[2] ? xopTXD2 :
                      TestMode[1] ? xipRXD2 :
                      TestMode[0] ? xipRXD1 : w_TxData;

wire w_TxClk;
wire w_RxClk;
wire w_RxReset_n;

always @ (posedge w_TxClk or negedge Reset_n)
	if(~Reset_n) r_divTxClk <= #`D 1'b0;
	else                          r_divTxClk <= #`D ~r_divTxClk;
	
/******************************************************************
*                       RS232-C Tx interface                      *
******************************************************************/
rsclk01a  i_TxClk (
	.gatedClk(w_TxClk),     // 1 bit output
	.BitRateSel(TxBitRate), // 4 bit input 
	.reset_n(Reset_n),      // 1 bit input 
	.F50Clk(RSClk)          // 1 bit input 
);

rstx_01a  rxtx_01a (
	.F50Clk(RSClk),
	.txParallelData(TxData),  // 8 bit input 
	.reset_n(Reset_n),        // 1 bit input 
	.txSerialData(w_TxData),  // 1 bit output
	.txTrigger(TxStart),      // 1 bit input 
	.tx_clk(w_TxClk),         // 1 bit input 
	.txStatus(TxStatus)       // 1 bit output
);

/******************************************************************
*                       RS232-C Rx interface                      *
******************************************************************/
rsclk01a  i_RxClk (
	.gatedClk(w_RxClk),     // 1 bit output
	.BitRateSel(RxBitRate), // 4 bit input 
	.reset_n(w_RxReset_n),  // 1 bit input 
	.F50Clk(RSClk)          // 1 bit input 
);

rsrx_01a  rxrx_01a (
	.rxParallelData(RxData),   // 8 bit output
	.rxStatus(RxStatus),       // 2 bit output
	.rx_clk(w_RxClk),          // 1 bit input 
	.rxSerialData(xipRXD1),    // 1 bit input 
	.reset_n(Reset_n),         // 1 bit input 
	.rxTrigger(RxFetch),       // 1 bit input 
	.sample_clk(RSClk),        // 1 bit input 
	.rxClkReset_n(w_RxReset_n) // 1 bit output
);

endmodule


`timescale 1ns/1ps

module top (
	xipMCLK,
	xipRESET,
	xonOE, xonWE, xopAddr,
	xonCE1, xonUB1, xonLB1, xbpDATA1,
	xonCE2, xonUB2, xonLB2, xbpDATA2,
	/*xopCAM_PWDN,*/
	xipCAM_VSYNC,
	xipCAM_HREF,
	xipCAM_PCLK,
	/*xipCAM_STROBE,*/
	xopCAM_XCLK,
	/*xonCAM_RESET,*/
	xopCAM_SIO_C,
	xbpCAM_SIO_D,
	xipCAM_D,
	xopTXD,
	/*xipRXD,*/
	xopLD7, xopLD6, xopLD5, xopLD4, xopLD3, xopLD2, xopLD1, xopLD0,
);
// System IO
input       xipMCLK;     // T9
input       xipRESET;    // L14

// SRAM interface
output        xonOE;     // K4
output        xonWE;     // G3
output [17:0] xopAddr;   // {L3,K5,K3,J3,J4,H4,H3,G5,E4,E3,F4,F3,G4,L4,M3,M4,N3,L5}
output        xonCE1;    // P7
output        xonUB1;    // T4
output        xonLB1;    // P6
inout  [15:0] xbpDATA1;  // {R1,P1,L2,J2,H1,F2,P8,D3,B1,C1,C2,R5,T5,R6,T8,N7}
output        xonCE2;    // N5
output        xonUB2;    // R4
output        xonLB2;    // P5
inout  [15:0] xbpDATA2;  // {N1,M1,K2,C3,F5,G1,E2,D2,D1,E1,G2,J1,K1,M2,N2,P2}

// Camera IO
//output      xopCAM_PWDN;
input       xipCAM_VSYNC;
input       xipCAM_HREF;
input       xipCAM_PCLK;
//input       xipCAM_STROBE; // open input (no use)
output      xopCAM_XCLK;
//output      xonCAM_RESET;
output      xopCAM_SIO_C;
inout       xbpCAM_SIO_D;
input [7:0] xipCAM_D;

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
//input       xipRXD;    // T13

/***********************************************
* clock & reset 
* *********************************************/
wire f50_clk;
wire f50_reset_n;
wire rs_clk;
wire rs_reset_n;
wire sccb_clk;
wire sccb_reset_n;
wire cam_clk;
wire cam_reset_n;
wire pixel_clk;
wire pixel_reset_n;

clk_reset clk_reset(
	.mclk          ( xipMCLK       ) ,
	.reset_n       ( ~xipRESET     ) ,
	.f50_clk       ( f50_clk       ) ,
	.f50_reset_n   ( f50_reset_n   ) ,
	.rs_clk        ( rs_clk        ) ,
	.rs_reset_n    ( rs_reset_n    ) ,
	.sccb_clk      ( sccb_clk      ) ,
	.sccb_reset_n  ( sccb_reset_n  ) ,
	.cam_clk       ( xopCAM_XCLK   ) ,
	.cam_reset_n   ( xonCAM_RESET  ) ,
	.pclk          ( xipCAM_PCLK   ) ,
	.pixel_clk     ( pixel_clk     ) ,
	.pixel_reset_n ( pixel_reset_n ) 
);

/***********************************************
* main sequencer 
* *********************************************/
wire sccb_kick;
wire sccb_done;
wire fetch_kick;
wire fetch_done;
wire dump_kick;
wire dump_done;
wire source_sel;
main_sequencer main_sequencer(
	.clk        ( f50_clk     ) ,
	.reset_n    ( f50_reset_n ) ,
	.sccb_kick  ( sccb_kick   ) ,
	.sccb_done  ( sccb_done   ) ,
	.fetch_kick ( fetch_kick  ) ,
	.fetch_done ( fetch_done  ) ,
	.dump_kick  ( dump_kick   ) ,
	.dump_done  ( dump_done   ) ,
	.source_sel ( source_sel  ) ,
	.led0       ( xopLD0      ) ,
	.led1       ( xopLD1      ) ,
	.led2       ( xopLD2      ) ,
	.led3       ( xopLD3      ) ,
	.led4       ( xopLD4      ) ,
	.led5       ( xopLD5      ) ,
	.led6       ( xopLD6      ) ,
	.led7       ( xopLD7      ) 
);

/***********************************************
* sccb 
* *********************************************/
wire  [7:0] w_sccb_div;
wire  [2:0] w_mcmd;
wire [14:0] w_maddr;
wire  [7:0] w_mdata;
wire        w_scmdaccept;
wire  [1:0] w_sresp;
wire  [7:0] w_sdata;
wire  [7:0] w_debug_out;

sccb_bridge sccb_bridge(
	.sccb_clk     ( sccb_clk     ) ,
	.sccb_reset_n ( sccb_reset_n ) ,
	.sccb_div     ( w_sccb_div   ) ,
	.sio_c        ( xopCAM_SIO_C ) ,
	.sio_d        ( xbpCAM_SIO_D ) ,
	.pwdn         ( xopCAM_PWDN  ) ,
	.mcmd         ( w_mcmd       ) ,
	.maddr        ( w_maddr      ) ,
	.mdata        ( w_mdata      ) ,
	.scmdaccept   ( w_scmdaccept ) ,
	.sresp        ( w_sresp      ) ,
	.sdata        ( w_sdata      ) ,
	.debug_out    ( w_debug_out  ) 
);

sccb_config sccb_config(
	.config_clk     ( sccb_clk     ) ,
	.config_reset_n ( sccb_reset_n ) ,
	.sccb_div       ( w_sccb_div   ) ,
	.sccb_kick      ( sccb_kick    ) ,
	.sccb_done      ( sccb_done    ) ,
	.mcmd           ( w_mcmd       ) ,
	.maddr          ( w_maddr      ) ,
	.mdata          ( w_mdata      ) ,
	.scmdaccept     ( w_scmdaccept ) ,
	.sresp          ( w_sresp      ) ,
	.sdata          ( w_sdata      ) 
);

/***********************************************
* RS232C
* *********************************************/
wire       rs_tx_start;
wire [7:0] rs_tx_data;
wire       rs_tx_status;
rsio_01a rsio_01a(
	.pavsv01a2rsio_01aRSClk     ( rs_clk       ) ,
	.pavsv01a2rsio_01aReset_n   ( rs_reset_n   ) ,
	.swdec01a2rsio_01aTestMode  ( 4'b0000      ) , // tie 0
	.dbgif01a2rsio_01aTxBitRate ( 4'h7         ) , // tie const
	.dbgif01a2rsio_01aTxStart   ( rs_tx_start  ) ,
	.dbgif01a2rsio_01aTxData    ( rs_tx_data   ) ,
	.rsio_01a2dbgif01aTxStatus  ( rs_tx_status ) ,
	.dbgif01a2rsio_01aRxBitRate ( 4'h7         ) , // tie const
	.dbgif01a2rsio_01aRxFetch   ( 1'b0         ) , // tie 0
	.rsio_01a2dbgif01aRxData    (              ) , // open
	.rsio_01a2dbgif01aRxStatus  (              ) , // open
	.xipRXD1                    ( xipRXD       ) ,
	.xopTXD1                    ( xopTXD       ) ,
	.xipRXD2                    ( 1'b0         ) , // tie 0
	.xopTXD2                    ( 1'b0         )   // tie 0
);

/***********************************************
* SRAM interface
* *********************************************/
wire        s0_WE;
wire [17:0] s0_Addr;
wire [31:0] s0_WD;
wire        s1_OE;
wire [17:0] s1_Addr;
wire [31:0] s1_RD;

sram_if sram_if(
	.source_sel ( source_sel ) ,
	.xonOE      ( xonOE      ) ,
	.xonWE      ( xonWE      ) ,
	.xopAddr    ( xopAddr    ) ,
	.xonCE1     ( xonCE1     ) ,
	.xonUB1     ( xonUB1     ) ,
	.xonLB1     ( xonLB1     ) ,
	.xbpDATA1   ( xbpDATA1   ) ,
	.xonCE2     ( xonCE2     ) ,
	.xonUB2     ( xonUB2     ) ,
	.xonLB2     ( xonLB2     ) ,
	.xbpDATA2   ( xbpDATA2   ) ,
	.s0_OE      ( 1'b1       ) , // no read
	.s0_WE      ( s0_WE      ) ,
	.s0_Addr    ( s0_Addr    ) ,
	.s0_WD      ( s0_WD      ) ,
	.s0_RD      (            ) , // no read, open
	.s1_OE      ( s1_OE      ) ,
	.s1_WE      ( 1'b1       ) , // no write
	.s1_Addr    ( s1_Addr    ) ,
	.s1_WD      ( 32'h0      ) , // no write
	.s1_RD      ( s1_RD      ) 
);

/***********************************************
* camera interface
* *********************************************/
wire [17:0] last_addr;
pixel_buffer pixel_buffer(
	.clk        ( pixel_clk     ) ,
	.reset_n    ( pixel_reset_n ) ,
	.fetch_kick ( fetch_kick    ) ,
	.fetch_done ( fetch_done    ) ,
	.VSYNC      ( xipCAM_VSYNC  ) ,
	.HREF       ( xipCAM_HREF   ) ,
	.DATA       ( xipCAM_D      ) ,
	.s0_WE      ( s0_WE         ) ,
	.s0_Addr    ( s0_Addr       ) ,
	.s0_WD      ( s0_WD         ) ,
	.last_addr  ( last_addr     )
);

/***********************************************
* dump sequencer
* *********************************************/
dump_sequencer dump_sequencer (
	.clk          ( rs_clk       ) ,
	.reset_n      ( rs_reset_n   ) ,
	.dump_kick    ( dump_kick    ) ,
	.dump_done    ( dump_done    ) ,
	.s1_OE        ( s1_OE        ) ,
	.s1_Addr      ( s1_Addr      ) ,
	.s1_RD        ( s1_RD        ) ,
	.rs_tx_start  ( rs_tx_start  ) ,
	.rs_tx_status ( rs_tx_status ) ,
	.rs_tx_data   ( rs_tx_data   ) ,
	.last_addr    ( last_addr    )
);

endmodule


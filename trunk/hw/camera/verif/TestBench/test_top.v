`timescale 1ns/1ns
module test_top;
`define MCLK_HCYCLE 10
`define PCLK_HCYCLE 12.5
`define SIM_TIME    200000000

reg xipMCLK;
reg xipRESET;
wire xipCAM_VSYNC;
wire xipCAM_HREF;
wire xipCAM_PCLK;
wire xipCAM_STROBE;
wire [7:0] xipCAM_D;
reg xipRXD;
wire [17:0] xopAddr;
wire xonCE1;
wire xonUB1;
wire xonLB1;
wire xonWE;
wire xonOE;
wire [15:0] xbpDATA1;
wire xonCE2;
wire xonUB2;
wire xonLB2;
wire [15:0] xbpDATA2;
wire xopCAM_PWDN;
wire xopCAM_XCLK;
wire xonCAM_RESET;
wire xopCAM_SIO_C;
wire xbpCAM_SIO_D;
wire xopTXD;
wire xopLD0;
wire xopLD1;
wire xopLD2;
wire xopLD3;
wire xopLD4;
wire xopLD5;
wire xopLD6;
wire xopLD7;

top top (
	.xipMCLK       ( xipMCLK       ) ,
	.xipRESET      ( xipRESET      ) ,
	.xonOE         ( xonOE         ) ,
	.xonWE         ( xonWE         ) ,
	.xopAddr       ( xopAddr       ) ,
	.xonCE1        ( xonCE1        ) ,
	.xonUB1        ( xonUB1        ) ,
	.xonLB1        ( xonLB1        ) ,
	.xbpDATA1      ( xbpDATA1      ) ,
	.xonCE2        ( xonCE2        ) ,
	.xonUB2        ( xonUB2        ) ,
	.xonLB2        ( xonLB2        ) ,
	.xbpDATA2      ( xbpDATA2      ) ,
	.xopCAM_PWDN   ( xopCAM_PWDN   ) ,
	.xipCAM_VSYNC  ( xipCAM_VSYNC  ) ,
	.xipCAM_HREF   ( xipCAM_HREF   ) ,
	.xipCAM_PCLK   ( xipCAM_PCLK   ) ,
	.xipCAM_STROBE ( xipCAM_STROBE ) ,
	.xopCAM_XCLK   ( xopCAM_XCLK   ) ,
	.xonCAM_RESET  ( xonCAM_RESET  ) ,
	.xopCAM_SIO_C  ( xopCAM_SIO_C  ) ,
	.xbpCAM_SIO_D  ( xbpCAM_SIO_D  ) ,
	.xipCAM_D      ( xipCAM_D      ) ,
	.xopTXD        ( xopTXD        ) ,
	.xipRXD        ( xipRXD        ) ,
	.xopLD7        ( xopLD7        ) ,
	.xopLD6        ( xopLD6        ) ,
	.xopLD5        ( xopLD5        ) ,
	.xopLD4        ( xopLD4        ) ,
	.xopLD3        ( xopLD3        ) ,
	.xopLD2        ( xopLD2        ) ,
	.xopLD1        ( xopLD1        ) ,
	.xopLD0        ( xopLD0        )
);

reg enable;
frame_driver frame_driver(
	.reset_n(enable),
	.PCLK(xipCAM_PCLK),
	.VSYNC(xipCAM_VSYNC),
	.HREF(xipCAM_HREF),
	.DATA(xipCAM_D)
);

async_sram sram_ch1 (
	.CE_N(xonCE1),
	.OE_N(xonOE),
	.WE_N(xonWE),
	.UB_N(xonUB1),
	.LB_N(xonLB1),
	.ADDR(xopAddr),
	.DATA(xbpDATA1)
);

async_sram sram_ch2 (
	.CE_N(xonCE2),
	.OE_N(xonOE),
	.WE_N(xonWE),
	.UB_N(xonUB2),
	.LB_N(xonLB2),
	.ADDR(xopAddr),
	.DATA(xbpDATA2)
);

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
	$dumpfile("test_top.lxt");
	$dumpvars(2, test_top.top.dump_sequencer);
	$dumpvars(2, test_top.top.sram_if);
end

initial begin
	xipRXD   = 1'b1;
	#`SIM_TIME $finish;
end

initial begin
	enable = 1'b0;
    wait(test_top.top.sccb_done);
	#1000
	enable = 1'b1;
end

endmodule

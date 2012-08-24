`timescale 1ns/1ps
`define D 1

// simple behavior model of Xilinx DCM
// CLKFX_OUT = CLKIN_IN x 5
module dcm_pll (
	CLKIN_IN,
	RST_IN,
	CLKFX_OUT,
	CLKIN_IBUFG_OUT,
	CLK0_OUT,
	LOCKED_OUT
);
input  CLKIN_IN;
input  RST_IN;
output CLKFX_OUT;
output CLKIN_IBUFG_OUT;
output CLK0_OUT;
output LOCKED_OUT;

reg r_clkx1;
reg r_clkx5;
assign CLKIN_IBUFG_OUT = CLKIN_IN;
assign CLK0_OUT        = LOCKED_OUT ? r_clkx1 : 1'bx;
assign CLKFX_OUT       = LOCKED_OUT ? r_clkx5 : 1'bx;

reg [3:0] r_lock_count;
assign LOCKED_OUT = &r_lock_count;

always @ (posedge CLKIN_IN or posedge RST_IN)
	if(RST_IN) r_lock_count <= #`D 4'h0;
	else       r_lock_count <= #`D LOCKED_OUT ? r_lock_count : r_lock_count + 4'h1;


always #50 
	if(RST_IN) r_clkx1 <= #`D 1'b0;
	else       r_clkx1 <= #`D ~r_clkx1;

always #10 
	if(RST_IN) r_clkx5 <= #`D 1'b0;
	else       r_clkx5 <= #`D ~r_clkx5;

endmodule


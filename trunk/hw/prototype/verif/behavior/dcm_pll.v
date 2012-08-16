`timescale 1ns/1ps

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

endmodule


`timescale 1ns/1ns
`define D 1

module clock_reset ( 
	refclk, reset_n, 
	mclk, mreset_n, 
	cam_clk, cam_reset_n, 
	pclk, pixelclk, preset_n,
	pll_lock_n
);
input  refclk;
input  reset_n;
output mclk;
output mreset_n;
output cam_clk;
output cam_reset_n;
input  pclk;
output pixelclk;
output preset_n;
output pll_lock_n;

wire w_refclk_reset_n;
wire w_pll_lock;
assign pll_lock_n = ~w_pll_lock;
wire clkx1;

// remove chattering 
wire w_buffered_ref;
syncd01a  i_reset_sync (
	.clk( w_buffered_ref ),           // 1 bit input 
	.reset_n(1'b1),           // 1 bit input 
	.d(reset_n),              // 1 bit input 
	.q(w_refclk_reset_n)      // 1 bit output
);

// DCM PLL
dcm_pll dcm_pll (
	.CLKIN_IN        ( refclk ),
	.RST_IN          ( ~w_refclk_reset_n ),
	.CLKFX_OUT       ( mclk ),
	.CLKIN_IBUFG_OUT ( w_buffered_ref ),
	.CLK0_OUT        ( ),
	.LOCKED_OUT      ( w_pll_lock )
);

// reset synchronization
rsync02a  i_reset_m (
	.clk(mclk),                               // 1 bit input 
	.reset_in(w_refclk_reset_n & w_pll_lock), // 1 bit input 
	.reset_out(mreset_n)                      // 1 bit output
);

rsync02a  i_reset_cam (
	.clk(cam_clk),                            // 1 bit input 
	.reset_in(w_refclk_reset_n & w_pll_lock), // 1 bit input 
	.reset_out(cam_reset_n)                   // 1 bit output
);

wire pclk_pre;
IBUFG p_bufi(.I(pclk),     .O(pclk_pre));
BUFG  p_buf (.I(pclk_pre), .O(pixelclk));

rsync02a  i_reset_p (
	.clk(pixelclk),                           // 1 bit input 
	.reset_in(w_refclk_reset_n & w_pll_lock), // 1 bit input 
	.reset_out(preset_n)                      // 1 bit output
);

reg cam_clk;
always @ (posedge mclk or negedge mreset_n)
	if(~mreset_n) cam_clk <= #`D 1'b0;
	else          cam_clk <= #`D ~cam_clk;


endmodule


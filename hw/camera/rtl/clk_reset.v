`timescale 1ns/1ns
`define D 1

module clk_reset ( mclk, reset_n, f50_clk, f50_reset_n,
	rs_clk, rs_reset_n, 
	sccb_clk, sccb_reset_n, 
	cam_clk, cam_reset_n, 
	pclk, pixel_clk, pixel_reset_n
);
input  mclk;           // 50MHz OSC
input  reset_n;        // External Switch
output f50_clk;        // buffered clk
output f50_reset_n;    // buffered clk

output rs_clk;         // RS232C clock : 25MHz (div2)
output rs_reset_n;     // RS232C reset

output sccb_clk;       // SCCB clock 
output sccb_reset_n;   // SCCB reset

output cam_clk;        // Reference clock for camera module
output cam_reset_n;    // Reset for camera module
input  pclk;           // pixel clock from camera module
output pixel_clk;      // pixel clock buffered
output pixel_reset_n;  // pixel reset 

// clock buffer
wire mclk_pre;
wire f50_clk;
IBUFG m_bufi(.I(mclk),     .O(mclk_pre));
BUFG  m_buf (.I(mclk_pre), .O(f50_clk));
wire pclk_pre;
IBUFG p_bufi(.I(pclk),     .O(pclk_pre));
BUFG  p_buf (.I(pclk_pre), .O(pixel_clk));

reg div2clk;

// clock division
always @ (posedge f50_clk or negedge f50_reset_n) 
	if(~f50_reset_n) div2clk <= #`D 1'b0;
	else                        div2clk <= #`D ~div2clk;

//reg sccb_clk;
//reg [7:0] r_divcnt;
//always @ (posedge f50_clk or negedge f50_reset_n) 
//	if(~f50_reset_n) begin
//		r_divcnt <= 8'h0;
//		sccb_clk <= 1'b0;
//	end else begin
//		r_divcnt <= r_divcnt + 8'h1;
//		sccb_clk <= r_divcnt[7];
//	end

assign rs_clk    = div2clk;
assign cam_clk   = div2clk;
assign sccb_clk  = div2clk;

// Reset synchronization
syncd01a  i_reset_sync (
	.clk(f50_clk),     // 1 bit input 
	.reset_n(1'b1),     // 1 bit input 
	.d(reset_n),        // 1 bit input 
	.q(f50_reset_n)     // 1 bit output
);

rsync02a  i_reset_rs (
	.clk(rs_clk),                       // 1 bit input 
	.reset_in(f50_reset_n),  // 1 bit input 
	.reset_out(rs_reset_n)              // 1 bit output
);
rsync02a  i_reset_sccb (
	.clk(sccb_clk),                     // 1 bit input 
	.reset_in(f50_reset_n),  // 1 bit input 
	.reset_out(sccb_reset_n)            // 1 bit output
);
rsync02a  i_reset_cam (
	.clk(cam_clk),                       // 1 bit input 
	.reset_in(f50_reset_n),   // 1 bit input 
	.reset_out(cam_reset_n)              // 1 bit output
);
rsync02a  i_reset_p (
	.clk(pixel_clk),                     // 1 bit input 
	.reset_in(f50_reset_n),   // 1 bit input 
	.reset_out(pixel_reset_n)            // 1 bit output
);

endmodule


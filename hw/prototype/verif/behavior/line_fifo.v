`timescale 1ns/1ps

/***************************************
*        Async FIFO : FPGA macro       *
* 32768 words, first word fall through *
***************************************/
module line_fifo (
	RST,
	WR_CLK,
	DIN,
	WR_EN,
	FULL,
	OVERFLOW,
	RD_CLK,
	DOUT,
	RD_EN,
	EMPTY,
	UNDERFLOW
);
input        RST;
input        WR_CLK;
input [7:0]  DIN;
input        WR_EN;
output       FULL;
output       OVERFLOW;
input        RD_CLK;
output [7:0] DOUT;
input        RD_EN;
output       EMPTY;
output       UNDERFLOW;

reg [7:0] buffer [0:32767];

reg [14:0] r_rptr;
reg [14:0] r_wptr;

assign DOUT = buffer[r_rptr];

wire w_rdrst_n;
wire w_wrrst_n;
assign w_wrrst_n = ~RST;

rsync02a rsync (
	.clk(RD_CLK),
	.reset_in(~RST),
	.reset_out(w_rdrst_n)
);

reg EMPTY;
reg UNDERFLOW;
always @ (posedge RD_CLK or negedge w_rdrst_n)
	if(~w_rdrst_n) begin
		r_rptr    <= 15'h00;
		EMPTY     <= 1'b0;
		UNDERFLOW <= 1'b0;
	end else begin
		r_rptr    <= RD_EN ? r_rptr + 15'h1 : r_rptr;
		EMPTY     <= (r_rptr + 15'h1 == r_wptr) ? 1'b1 : 1'b0;
		UNDERFLOW <= RD_EN & EMPTY ? 1'b1 : UNDERFLOW ? 1'b1 : 1'b0;
	end

reg FULL;
reg OVERFLOW;
reg r_fullmask;
always @ (posedge WR_CLK or negedge w_wrrst_n)
	if(~w_wrrst_n) begin
		r_wptr     <= 15'h00;
		FULL       <= 1'b0;
		OVERFLOW   <= 1'b0;
		r_fullmask <= 1'b0;
	end else begin
		buffer[r_wptr] <= WR_EN ? DIN : buffer[r_wptr]; 
		r_wptr     <= WR_EN ? r_wptr + 15'h1 : r_wptr;
		FULL       <= (r_rptr == r_wptr) ? r_fullmask : 1'b0;
		OVERFLOW   <= (WR_EN & FULL) ? 1'b1 : OVERFLOW ? 1'b1 : 1'b0;
		r_fullmask <= WR_EN ? 1'b1 : r_fullmask ? 1'b1 : 1'b0;
	end

endmodule


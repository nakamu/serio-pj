`timescale 1ns/1ps

/***************************************
*        Async FIFO : FPGA macro       *
* 32768 words, first word fall through *
***************************************/
module line_fifo (
	rst,
	wr_clk,
	din,
	wr_en,
	full,
	overflow,
	rd_clk,
	dout,
	rd_en,
	empty,
	underflow
);
input        rst;
input        wr_clk;
input  [7:0] din;
input        wr_en;
output       full;
output       overflow;
input        rd_clk;
output [7:0] dout;
input        rd_en;
output       empty;
output       underflow;

reg [7:0] buffer [0:32767];

reg [14:0] r_rptr;
reg [14:0] r_wptr;

assign dout = buffer[r_rptr];

wire w_rdrst_n;
wire w_wrrst_n;
assign w_wrrst_n = ~rst;

rsync02a rsync (
	.clk(rd_clk),
	.reset_in(~rst),
	.reset_out(w_rdrst_n)
);

reg empty;
reg underflow;
always @ (posedge rd_clk or negedge w_rdrst_n)
	if(~w_rdrst_n) begin
		r_rptr    <= 15'h00;
		empty     <= 1'b0;
		underflow <= 1'b0;
	end else begin
		r_rptr    <= rd_en ? r_rptr + 15'h1 : r_rptr;
		empty     <= (r_rptr + 15'h1 == r_wptr) ? 1'b1 : 1'b0;
		underflow <= rd_en & empty ? 1'b1 : underflow ? 1'b1 : 1'b0;
	end

reg full;
reg overflow;
reg r_fullmask;
always @ (posedge wr_clk or negedge w_wrrst_n)
	if(~w_wrrst_n) begin
		r_wptr     <= 15'h00;
		full       <= 1'b0;
		overflow   <= 1'b0;
		r_fullmask <= 1'b0;
	end else begin
		buffer[r_wptr] <= wr_en ? din : buffer[r_wptr]; 
		r_wptr     <= wr_en ? r_wptr + 15'h1 : r_wptr;
		full       <= (r_rptr == r_wptr) ? r_fullmask : 1'b0;
		overflow   <= (wr_en & full) ? 1'b1 : overflow ? 1'b1 : 1'b0;
		r_fullmask <= wr_en ? 1'b1 : r_fullmask ? 1'b1 : 1'b0;
	end

endmodule


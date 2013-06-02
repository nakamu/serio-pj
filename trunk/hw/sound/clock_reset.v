`timescale 1ns/1ps

module clock_reset(xclkin, reset_n, baseclk, asyncrst_n);
input  xclkin;
input  reset_n;
output baseclk;
output asyncrst_n;

// clock buffering
wire baseclk_pre;
IBUFG clk_bufi (.I(xclkin),      .O(baseclk_pre));
BUFG  clk_buf  (.I(baseclk_pre), .O(baseclk));

reg reset_pre0;
reg reset_pre1;


// remove noise 
always @ (posedge baseclk) begin
	reset_pre0 <= reset_n;
	reset_pre1 <= reset_pre0;
end

reg rsync;
reg asyncrst_n;

always @ (posedge baseclk or negedge reset_pre1)
	if(~reset_pre1) begin
		rsync      <= 1'b0;
		asyncrst_n <= 1'b0;
	end else begin
		rsync      <= 1'b1;
		asyncrst_n <= rsync;
	end

endmodule

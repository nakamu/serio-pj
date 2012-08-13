`timescale 1ns/1ps
`define    D  1

module glmux (oclk, aclk, arst_n, bclk, brst_n, sel);
output oclk;
input  aclk;
input  bclk;
input  arst_n;
input  brst_n;
input  sel;

reg r_aen_pre1;
reg r_aen_pre2;
reg r_ben_pre1;
reg r_ben_pre2;

always @ (posedge aclk or negedge arst_n)
	if(~arst_n) begin
		r_aen_pre1 <= #`D 1'b0;
		r_aen_pre2 <= #`D 1'b0;
	end else begin
		r_aen_pre1 <= #`D !sel & !r_ben_pre2;
		r_aen_pre2 <= #`D r_aen_pre1;
	end

always @ (posedge bclk or negedge brst_n)
	if(~brst_n) begin
		r_ben_pre1 <= #`D 1'b0;
		r_ben_pre2 <= #`D 1'b0;
	end else begin
		r_ben_pre1 <= #`D  sel & !r_aen_pre2;
		r_ben_pre2 <= #`D r_ben_pre1;
	end

wire w_aclkout;
wire w_bclkout;
cgate01a cgate_a(.clk(aclk), .en(r_aen_pre2), .test(1'b0), .gclk(w_aclkout));
cgate01a cgate_b(.clk(bclk), .en(r_ben_pre2), .test(1'b0), .gclk(w_bclkout));

assign oclk = w_aclkout | w_bclkout;

endmodule


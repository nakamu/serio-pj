`timescale 1ns/1ns
`define D 1

module main_sequencer (
	clk, reset_n,
	sccb_kick, sccb_done,
	fetch_kick, fetch_done,
	dump_kick, dump_done,
	source_sel,
	led0, led1, led2, led3, led4, led5, led6, led7
);
input clk;
input reset_n;

output	sccb_kick;
input   sccb_done;

output fetch_kick;
input  fetch_done;

output dump_kick;
input  dump_done;

output source_sel;

output led0;
output led1;
output led2;
output led3;
output led4;
output led5;
output led6;
output led7;

parameter SEQ_INIT          = 3'd0;
parameter SEQ_SCCB_KICKED   = 3'd1;
parameter SEQ_SCCB_DONE     = 3'd2;
parameter SEQ_FETCH_KICKED  = 3'd3;
parameter SEQ_FETCH_DONE    = 3'd4;
parameter SEQ_DUMP_KICKED   = 3'd5;
parameter SEQ_END           = 3'd6;

reg [2:0] r_seq_state;
reg       sccb_kick;
reg       fetch_kick;
reg       dump_kick;

assign led0 = 1'b1;
assign led1 = r_seq_state > SEQ_INIT;
assign led2 = r_seq_state > SEQ_SCCB_KICKED;
assign led3 = r_seq_state > SEQ_SCCB_DONE;
assign led4 = r_seq_state > SEQ_FETCH_KICKED;
assign led5 = r_seq_state > SEQ_FETCH_DONE;
assign led6 = r_seq_state > SEQ_DUMP_KICKED;
assign led7 = 1'b0;


// sync input flag
wire sccb_done_sync;
syncd01a syncd_sccb_done (
	.clk     (clk),
	.reset_n (reset_n),
	.d       (sccb_done),
	.q       (sccb_done_sync)
);
wire fetch_done_sync;
syncd01a syncd_fetch_done (
	.clk     (clk),
	.reset_n (reset_n),
	.d       (fetch_done),
	.q       (fetch_done_sync)
);
wire dump_done_sync;
syncd01a syncd_dump_done (
	.clk     (clk),
	.reset_n (reset_n),
	.d       (dump_done),
	.q       (dump_done_sync)
);

reg source_sel;

always @ (posedge clk or negedge reset_n) 
	if(~reset_n) begin
		r_seq_state <= SEQ_INIT;
//		r_seq_state <= SEQ_SCCB_DONE;
		source_sel  <= 1'b0;
		sccb_kick   <= 1'b0;
		fetch_kick  <= 1'b0;
		dump_kick   <= 1'b0;
	end else begin
		case(r_seq_state) 
			SEQ_INIT : begin
				sccb_kick   <= 1'b1;
				r_seq_state <= SEQ_SCCB_KICKED;
			end
			SEQ_SCCB_KICKED : begin
				sccb_kick   <= sccb_done_sync ? 1'b0 : sccb_kick;
				r_seq_state <= sccb_done_sync ? SEQ_SCCB_DONE : r_seq_state;  
			end
			SEQ_SCCB_DONE : begin
				fetch_kick  <= 1'b1;
				r_seq_state <= SEQ_FETCH_KICKED;
			end
			SEQ_FETCH_KICKED : begin
				fetch_kick  <= fetch_done_sync ? 1'b0 : fetch_kick;
				r_seq_state <= fetch_done_sync ? SEQ_FETCH_DONE : r_seq_state;
			end
			SEQ_FETCH_DONE : begin
				source_sel  <= 1'b1;
				dump_kick   <= 1'b1;
				r_seq_state <= SEQ_DUMP_KICKED;
			end
			SEQ_DUMP_KICKED : begin
				dump_kick   <= dump_done_sync ? 1'b0    : dump_kick;
				r_seq_state <= dump_done_sync ? SEQ_END : r_seq_state;
			end
		endcase
	end

endmodule


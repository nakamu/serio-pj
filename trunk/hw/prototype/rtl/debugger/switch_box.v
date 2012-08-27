`timescale 1ns/1ps
module switch_box(
	clk,
	reset_n,
	sw1, sw2, sw3, sw4,
	edge1, edge2, edge3, edge4,
	pushing
);
input clk;
input reset_n;
input sw1;
input sw2;
input sw3;
input sw4;
output edge1;
output edge2;
output edge3;
output edge4;
output pushing;

// synchronize input
wire w_sw1_synced;
wire w_sw2_synced;
wire w_sw3_synced;
wire w_sw4_synced;
syncd01a sync_sw1(
	.clk(clk), 
	.reset_n(reset_n),
	.d(sw1),
	.q(w_sw1_synced)
);
syncd01a sync_sw2(
	.clk(clk), 
	.reset_n(reset_n),
	.d(sw2),
	.q(w_sw2_synced)
);
syncd01a sync_sw3(
	.clk(clk), 
	.reset_n(reset_n),
	.d(sw3),
	.q(w_sw3_synced)
);
syncd01a sync_sw4(
	.clk(clk), 
	.reset_n(reset_n),
	.d(sw4),
	.q(w_sw4_synced)
);
// switch trigger
trigp01a posedge_sw1(
	.clk(clk), 
	.reset_n(reset_n),
	.in(w_sw1_synced),
	.trigger(edge1)
);
trigp01a posedge_sw2(
	.clk(clk), 
	.reset_n(reset_n),
	.in(w_sw2_synced),
	.trigger(edge2)
);
trigp01a posedge_sw3(
	.clk(clk), 
	.reset_n(reset_n),
	.in(w_sw3_synced),
	.trigger(edge3)
);
trigp01a posedge_sw4(
	.clk(clk), 
	.reset_n(reset_n),
	.in(w_sw4_synced),
	.trigger(edge4)
);

assign pushing = w_sw1_synced | w_sw2_synced | w_sw3_synced | w_sw4_synced;

endmodule

`timescale 1ns/1ps
`define D 1

module async_sram (
	OE_N, WE_N, CE_N, UB_N, LB_N, 
	ADDR, DATA
);

input OE_N;
input WE_N;
input CE_N;
input UB_N;
input LB_N;
input [17:0] ADDR;
inout [15:0] DATA;

reg [15:0] mem [0:262143];

assign DATA = OE_N ? 16'hz : 
	{(UB_N ? 8'hz : mem[ADDR][15:8]), (LB_N ? 8'hz : mem[ADDR][7:0])};

always @ (CE_N or WE_N or UB_N or LB_N or ADDR or DATA) 
	if(~CE_N & ~WE_N) begin
		if(~UB_N)
			mem[ADDR][15:8] <= DATA[15:8];
		if(~LB_N)
			mem[ADDR][7:0]  <= DATA[7:0];
	end


endmodule

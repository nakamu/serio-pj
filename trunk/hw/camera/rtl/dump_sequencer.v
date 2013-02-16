`timescale 1ns/1ns
`define D 1

module dump_sequencer (
	clk, reset_n,
	dump_kick, dump_done,
	s1_OE, s1_Addr, s1_RD,
	rs_tx_start, rs_tx_data, rs_tx_status,
	last_addr,
	rest
);
input         clk;
input         reset_n;
input         dump_kick;
output        dump_done;
output        s1_OE;
output [17:0] s1_Addr;
input  [31:0] s1_RD;
output        rs_tx_start;
output  [7:0] rs_tx_data;
input         rs_tx_status;
input  [17:0] last_addr;
output [15:0] rest;

wire [18:0] sub;
assign sub = {1'b0,last_addr} - {1'b0, s1_Addr};
assign rest = sub[17:2];

wire dump_kick_sync;
syncd01a syncd_dump_kick (
	.clk(clk),
	.reset_n(reset_n),
	.d(dump_kick),
	.q(dump_kick_sync)
);

function [7:0] convert_ascii;
input [3:0] hex;
	if(hex < 4'ha) 
		convert_ascii = 8'h30+{4'h0,hex};
	else 
		convert_ascii = 8'h37+{4'h0,hex};
endfunction

reg [2:0] dumper_state;
parameter P_STATE_INIT          = 3'd0;
parameter P_STATE_START         = 3'd1;
parameter P_STATE_READMEM       = 3'd2;
parameter P_STATE_CONVERT_ASCII = 3'd3;
parameter P_STATE_DUMP0         = 3'd4;
parameter P_STATE_DUMP1         = 3'd5;
parameter P_STATE_END           = 3'd6;

reg        dump_done;
reg        s1_OE;
reg [17:0] s1_Addr;
reg [31:0] data_buffer;
reg        rs_tx_start;
reg  [7:0] rs_tx_data;
integer i;
reg  [3:0] send_ptr;
reg  [7:0] send_data[0:11];

always @ (posedge clk or negedge reset_n)
	if(~reset_n) begin
		dumper_state <= P_STATE_INIT;
		dump_done    <= 1'b0;
		s1_OE        <= 1'b1;
		s1_Addr      <= 18'h3ffff;
		data_buffer  <= 32'h0;
		rs_tx_start  <= 1'b0;
		rs_tx_data   <= 8'h00;
		for(i=0; i<12; i=i+1) begin
			send_data[i] <= 8'h20;
		end
		send_ptr     <= 4'h0;
	end else begin
		case(dumper_state) 
			P_STATE_INIT: begin
				if(dump_kick_sync) 
					dumper_state <= P_STATE_START;
			end
			P_STATE_START: begin
				if((s1_Addr != 18'h3ffff) & (s1_Addr > last_addr)) begin
					dump_done    <= 1'b1;
					dumper_state <= P_STATE_END;
				end else begin
					s1_Addr      <= s1_Addr + 18'h1;
					s1_OE        <= 1'b0;
					dumper_state <= P_STATE_READMEM;
				end
			end
			P_STATE_READMEM : begin
				s1_OE        <= 1'b1;
				data_buffer  <= s1_RD;
				dumper_state <= P_STATE_CONVERT_ASCII;
			end
			P_STATE_CONVERT_ASCII : begin
				send_data[0]  <= convert_ascii(data_buffer[3:0]);
				send_data[1]  <= convert_ascii(data_buffer[7:4]);
				send_data[2]  <= 8'h20;
				send_data[3]  <= convert_ascii(data_buffer[11:8]);
				send_data[4]  <= convert_ascii(data_buffer[15:12]);
				send_data[5]  <= 8'h20;
				send_data[6]  <= convert_ascii(data_buffer[19:16]);
				send_data[7]  <= convert_ascii(data_buffer[23:20]);
				send_data[8]  <= 8'h20;
				send_data[9]  <= convert_ascii(data_buffer[27:24]);
				send_data[10] <= convert_ascii(data_buffer[31:28]);
				send_data[11] <= 8'h0a;
				dumper_state  <= P_STATE_DUMP0;
			end
			P_STATE_DUMP0 : begin
				if(send_ptr == 4'd12) begin
					send_ptr     <= 4'h0;
					dumper_state <= P_STATE_START;
				end else begin
					if(~rs_tx_status) begin
						rs_tx_start  <= 1'b1;
						rs_tx_data   <= send_data[send_ptr];
						send_ptr     <= send_ptr + 4'h1;
						dumper_state <= P_STATE_DUMP1;
					end
				end
			end
			P_STATE_DUMP1 : begin
				rs_tx_start  <= 1'b0;
				dumper_state <= P_STATE_DUMP0;
			end
			default : begin
				dumper_state <= P_STATE_END;
			end
		endcase
	end

endmodule

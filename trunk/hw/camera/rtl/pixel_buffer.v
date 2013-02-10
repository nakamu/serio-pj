`timescale 1ns/1ps
`define    D  1

module pixel_buffer (
	clk,
	reset_n,
	fetch_kick,
	fetch_done,
	VSYNC,
	HREF,
	DATA,
	s0_WE,
	s0_Addr,
	s0_WD,
	last_addr
);
input         clk;
input         reset_n;
input         fetch_kick;
output        fetch_done;
input         VSYNC;
input         HREF;
input   [7:0] DATA;
output        s0_WE;
output [17:0] s0_Addr;
output [31:0] s0_WD;
output [17:0] last_addr;

// retime inputs
reg r_VSYNC;
reg r_HREF_pre;
reg r_HREF;
reg [7:0] r_DATA_pre;
reg [7:0] r_DATA;
always @ (posedge clk or negedge reset_n)
	if(~reset_n) begin
		r_VSYNC    <= #`D 1'b0;
		r_HREF_pre <= #`D 1'b0;
		r_HREF     <= #`D 1'b0;
		r_DATA_pre <= #`D 8'h00;
		r_DATA     <= #`D 8'h00;
	end else begin
		r_VSYNC    <= #`D VSYNC;
		r_HREF_pre <= #`D HREF;
		r_HREF     <= #`D r_HREF_pre;
		r_DATA_pre <= #`D DATA;
		r_DATA     <= #`D r_DATA_pre;
	end

wire w_frame_start;
trigp01a vsync_trigger (
	.clk(clk),
	.reset_n(reset_n),
	.in(r_VSYNC),
	.trigger(w_frame_start)
);

wire fetch_kick_sync;
syncd01a syncd_fetch_kick (
	.clk(clk),
	.reset_n(reset_n),
	.d(fetch_kick),
	.q(fetch_kick_sync)
);

reg [1:0] r_HREF_cnt;
always @ (posedge clk or negedge reset_n) 
	if(~reset_n) begin
		r_HREF_cnt <= 2'b00;
	end else begin
		if(w_frame_start) 
			r_HREF_cnt <= 2'b00;
		else if(r_HREF) 
			r_HREF_cnt <= r_HREF_cnt + 2'b01;
	end

reg  [3:0] r_cap_state;
reg [31:0] r_data_buffer;
reg        fetch_done;

parameter P_STATE_INIT    = 2'b00;
parameter P_STATE_RUNNING = 2'b01;
parameter P_STATE_END     = 2'b10;

always @ (posedge clk or negedge reset_n) 
	if(~reset_n) begin
		r_cap_state <= P_STATE_INIT;
		fetch_done  <= 1'b0;
	end else begin
		case(r_cap_state) 
			P_STATE_INIT: begin
				if(w_frame_start & fetch_kick_sync) begin
					r_cap_state <= P_STATE_RUNNING;
				end
			end
			P_STATE_RUNNING: begin
				if(w_frame_start) begin
					r_cap_state <= P_STATE_END;
					fetch_done  <= 1'b1;
				end
			end
		endcase
	end

always @ (posedge clk or negedge reset_n) 
	if(~reset_n) begin
		r_data_buffer <= 32'h0;
	end else begin
		if(r_HREF) begin
			r_data_buffer <= {r_DATA, r_data_buffer[31:8]};
		end
	end

reg        s0_WE;
reg [17:0] s0_Addr;
reg [31:0] s0_WD;
always @ (posedge clk or negedge reset_n) 
	if(~reset_n) begin
		s0_WE   <= 1'b1;
		s0_Addr <= 18'h3ffff;
		s0_WD   <= 32'h0;
	end else begin
		if(r_cap_state != P_STATE_RUNNING) begin
			s0_WE   <= 1'b1;
			s0_Addr <= 18'h3ffff;
			s0_WD   <= 32'h0;
		end else if((r_HREF_cnt == 2'b11) & r_HREF) begin
			s0_WE   <= 1'b0;
			s0_Addr <= s0_Addr + 18'h1;
			s0_WD   <= {r_DATA, r_data_buffer[31:8]};
		end else begin
			s0_WE   <= 1'b1;
		end
	end

reg [17:0] last_addr;
always @ (posedge clk or negedge reset_n) 
	if(~reset_n) begin
		last_addr <= 18'h0;
	end else begin
		if((s0_Addr != 18'h3ffff)&(r_cap_state==P_STATE_RUNNING)) begin
			if(last_addr < s0_Addr) 
				last_addr <= s0_Addr;
		end
	end

endmodule


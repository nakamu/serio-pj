`timescale 1ns/1ps
`define D 1

module uart_transaction (
	clk,
	reset_n,
	RXD1,
	TXD1,
	uart_MCmd,
	uart_MAddr,
	uart_MData,
	uart_SCmdAccept,
	uart_SData,
	uart_SResp,
	uart_active_n,
);

input        clk;
input        reset_n;
input        RXD1;
output       TXD1;
output [2:0] uart_MCmd;
output [7:0] uart_MAddr;
output [7:0] uart_MData;
input        uart_SCmdAccept;
input  [7:0] uart_SData;
input  [1:0] uart_SResp;
output       uart_active_n;

wire       w_tx_start;
wire [7:0] w_tx_data;
wire       w_tx_status;

wire       w_rx_fetch;
wire [7:0] w_rx_data;
wire [1:0] w_rx_status;

uart_io uart_io (
	.RSClk     ( clk ),
	.Reset_n   ( reset_n ),
	.TestMode  ( 4'b0000 ),
	.TxBitRate ( 4'b1111 ), // 6.25Mbps
	.TxStart   ( w_tx_start ),
	.TxData    ( w_tx_data ),
	.TxStatus  ( w_tx_status ),
	.RxBitRate ( 4'b1111 ), // 6.25Mbps
	.RxFetch   ( w_rx_fetch ),
	.RxData    ( w_rx_data ),
	.RxStatus  ( w_rx_status),
	.xipRXD1   ( RXD1 ),
	.xopTXD1   ( TXD1 ),
	.xipRXD2   ( 1'b0 ),
	.xopTXD2   ( 1'b0 )
);

/**************************************************
*            Request path State machine           *
**************************************************/
parameter P_STATE_IDLE          = 4'h0;
parameter P_STATE_FETCH_CMD     = 4'h1;
parameter P_STATE_FETCH_ADDR0   = 4'h2;
parameter P_STATE_FETCH_ADDR1   = 4'h3;
parameter P_STATE_FETCH_BURST0  = 4'h4;
parameter P_STATE_FETCH_BURST1  = 4'h5;
parameter P_STATE_FETCH_WRD0    = 4'h6;
parameter P_STATE_FETCH_WRD1    = 4'h7;
parameter P_STATE_ISSUE_CMD     = 4'h8;
parameter P_STATE_CMD_HANDSHAKE = 4'h9;

reg [3:0] r_req_state;
reg [7:0] r_burst_counter;
reg       r_burst_flag;
reg       r_burst_type;
reg       r_outstanding;
reg [2:0] r_MCmd_pre;
reg [2:0] r_MCmd;
reg [7:0] r_MAddr;
reg [7:0] r_MData;

reg    r_rx_fetch;
assign w_rx_fetch = r_rx_fetch;

wire   w_acceptable_cmd;
assign w_acceptable_cmd = (w_rx_data[2:0] == 3'b001) | (w_rx_data[2:0] == 3'b010);

wire [7:0] w_burst_counter;
assign w_burst_counter = r_burst_counter - 8'h1;

wire [7:0] w_MAddr_next;
assign w_MAddr_next = r_burst_type ? r_MAddr : r_MAddr + 8'h1;

wire w_WR_cmd;
wire w_RD_cmd;
assign w_WR_cmd = (r_MCmd_pre == 3'b001);
assign w_RD_cmd = (r_MCmd_pre == 3'b010);

assign uart_MAddr = r_MAddr;
assign uart_MCmd  = r_MCmd;
assign uart_MData = r_MData;
assign uart_active_n = ~w_tx_status;

always @ (posedge clk or negedge reset_n)
	if(~reset_n) begin
		r_req_state     <= #`D P_STATE_IDLE;
		r_burst_counter <= #`D 8'h00;
		r_burst_flag    <= #`D 1'b0;
		r_burst_type    <= #`D 1'b0;
		r_MCmd_pre      <= #`D 3'b000;
		r_MCmd          <= #`D 3'b000;
		r_MAddr         <= #`D 8'h00;
		r_MData         <= #`D 8'h00;
		r_rx_fetch      <= #`D 1'b0;
	end else begin
		case(r_req_state)
		P_STATE_IDLE : begin
			if(w_rx_status[1]) begin
				r_req_state <= #`D P_STATE_FETCH_CMD;
				r_rx_fetch  <= #`D 1'b1;
			end
		end
		P_STATE_FETCH_CMD : begin
			if(w_acceptable_cmd) begin
				r_req_state  <= #`D P_STATE_FETCH_ADDR0;
				r_MCmd_pre   <= #`D w_rx_data[2:0];
				r_burst_flag <= #`D w_rx_data[4];
				r_burst_type <= #`D w_rx_data[5];
			end else begin
				r_req_state  <= #`D P_STATE_IDLE;
			end
			r_rx_fetch       <= #`D 1'b0;
		end
		P_STATE_FETCH_ADDR0 : begin
			if(w_rx_status[1]) begin
				r_req_state <= #`D P_STATE_FETCH_ADDR1;
				r_rx_fetch  <= #`D 1'b1;
			end
		end
		P_STATE_FETCH_ADDR1 : begin
			r_rx_fetch       <= #`D 1'b0;
			r_MAddr          <= #`D w_rx_data;
			if(r_burst_flag)
				r_req_state  <= #`D P_STATE_FETCH_BURST0;
			else if(w_WR_cmd)
				r_req_state  <= #`D P_STATE_FETCH_WRD0;
			else begin
				r_req_state  <= #`D P_STATE_ISSUE_CMD;
			end
		end
		P_STATE_FETCH_BURST0 : begin
			if(w_rx_status[1]) begin
				r_req_state <= #`D P_STATE_FETCH_BURST1;
				r_rx_fetch  <= #`D 1'b1;
			end
		end
		P_STATE_FETCH_BURST1 : begin
			r_rx_fetch       <= #`D 1'b0;
			r_burst_counter  <= #`D w_rx_data;
			if(w_WR_cmd)
				r_req_state  <= #`D P_STATE_FETCH_WRD0;
			else begin
				r_req_state  <= #`D P_STATE_ISSUE_CMD;
			end
		end
		P_STATE_FETCH_WRD0 : begin
			if(w_rx_status[1]) begin
				r_req_state <= #`D P_STATE_FETCH_WRD1;
				r_rx_fetch  <= #`D 1'b1;
			end
		end
		P_STATE_FETCH_WRD1 : begin
			r_rx_fetch  <= #`D 1'b0;
			r_req_state <= #`D P_STATE_ISSUE_CMD;
			r_MData     <= #`D w_rx_data;
		end
		P_STATE_ISSUE_CMD : begin
			if(~r_outstanding) begin
				r_req_state <= #`D P_STATE_CMD_HANDSHAKE;
				r_MCmd  <= #`D r_MCmd_pre;
			end
		end
		P_STATE_CMD_HANDSHAKE : begin
			if(uart_SCmdAccept) begin
				r_MCmd              <= #`D 3'b000;
				if(r_burst_counter == 8'h00) begin
					r_req_state     <= #`D P_STATE_IDLE;
				end else begin
					r_burst_counter <= #`D w_burst_counter;
					r_MAddr         <= #`D w_MAddr_next;
					if(w_WR_cmd)
						r_req_state     <= #`D P_STATE_FETCH_WRD0;
					else 
						r_req_state     <= #`D P_STATE_ISSUE_CMD;
				end
			end
		end
		default : r_req_state <= #`D P_STATE_IDLE;
		endcase
	end

/**************************************************
*        outstanding transaction limitter         *
*            can't issue next cmd                 *
*         until this I/F receives response        *
**************************************************/
reg r_pre_unlock;
always @ (posedge clk or negedge reset_n)
	if(~reset_n) begin
		r_outstanding <= #`D 1'b0;
		r_pre_unlock  <= #`D 1'b0;
	end else begin
		if(r_MCmd == 3'b010 & uart_SCmdAccept) begin
			// read request issued
			r_outstanding <= #`D 1'b1;
		end else if(~r_pre_unlock & r_tx_start) begin
			// read response has passed to UART Tx
			r_pre_unlock  <= #`D 1'b1;
		end else if(r_pre_unlock & ~w_tx_status) begin
			// UART Tx is now idle, OK to issue next command
			r_outstanding <= #`D 1'b0;
			r_pre_unlock  <= #`D 1'b0;
		end
	end

/**************************************************
*           Response path State machine           *
**************************************************/
parameter P_STATE_CAPTURE = 1'b0;
parameter P_STATE_TX_KICK = 1'b1;
reg       r_resp_state;
reg       r_tx_start;
reg [7:0] r_tx_data;

assign w_tx_start = r_tx_start;
assign w_tx_data  = r_tx_data;

always @ (posedge clk or negedge reset_n)
	if(~reset_n) begin
		r_resp_state <= #`D P_STATE_CAPTURE;
		r_tx_start   <= #`D 1'b0;
		r_tx_data    <= #`D 8'h00;
	end else begin
		case(r_resp_state)
		P_STATE_CAPTURE : begin
			r_tx_start       <= #`D 1'b0;
			if(uart_SResp == 2'b01) begin
				r_resp_state <= #`D P_STATE_TX_KICK;
				r_tx_data    <= #`D uart_SData;
			end else if(uart_SResp[1]) begin
				r_resp_state <= #`D P_STATE_TX_KICK;
				r_tx_data    <= #`D 8'hed;
			end
		end
		P_STATE_TX_KICK : begin
			if(~w_tx_status) begin
				r_tx_start   <= #`D 1'b1;
				r_resp_state <= #`D P_STATE_CAPTURE;
			end
		end
		endcase
	end

endmodule


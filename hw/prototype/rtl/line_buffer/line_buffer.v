`timescale 1ns/1ps
`define    D  1

module line_buffer (
	writeClk,
	writeRst_n,
	VSYNC,
	HREF,
	DATA,
	readClk,
	readRst_n,
	linebuf_MCmd,
	linebuf_MAddr,
	linebuf_MData,
	linebuf_SCmdAccept,
	linebuf_SData,
	linebuf_SResp
);
input        writeClk;
input        writeRst_n;
input        VSYNC;
input        HREF;
input  [7:0] DATA;
input        readClk;
input        readRst_n;
input  [2:0] linebuf_MCmd;
input  [7:0] linebuf_MAddr;
input  [7:0] linebuf_MData;
output       linebuf_SCmdAccept;
output [7:0] linebuf_SData;
output [1:0] linebuf_SResp;

/***************************************
*                Bus I/F               *
***************************************/
wire w_write_enable;
wire w_read_enable;
assign w_write_enable = (linebuf_MCmd == 3'b001) ? 1'b1 : 1'b0;
assign w_read_enable  = (linebuf_MCmd == 3'b010) ? 1'b1 : 1'b0;

reg r_read_enable;
always @ (posedge readClk or negedge readRst_n)
	if(~readRst_n) r_read_enable <= #`D 1'b0;
	else           r_read_enable <= #`D w_read_enable;

assign linebuf_SCmdAccept = 1'b1;
assign linebuf_SResp      = {1'b0, r_read_enable};

reg  [7:0] linebuf_SData;
wire [7:0] w_read_data;
reg        r_capture_start;
wire       w_capture_end;
reg  [8:0] r_line_addr;
reg  [4:0] r_line_size;
wire [3:0] w_fifo_status;
reg        r_kicked;
wire       w_kicked;

always @ (posedge readClk or negedge readRst_n)
	if(~readRst_n) begin
		linebuf_SData   <= #`D 8'h00;
		r_capture_start <= #`D 1'b0;
		r_line_addr     <= #`D 9'h000;
		r_line_size     <= #`D 5'd20; // 20
	end else begin
		if(w_read_enable) 
			case(linebuf_MAddr[6:0])
			7'h00 : linebuf_SData <= #`D w_read_data;
			7'h10 : linebuf_SData <= #`D {7'h00, r_capture_start};
			7'h14 : linebuf_SData <= #`D {7'h00, w_capture_end};
			7'h20 : linebuf_SData <= #`D r_line_addr[7:0];
			7'h21 : linebuf_SData <= #`D {7'h00, r_line_addr[8]};
			7'h30 : linebuf_SData <= #`D {3'h0,  r_line_size};
			7'h70 : linebuf_SData <= #`D {2'b00, w_fifo_status[1:0], 2'b00, w_fifo_status[3:2]};
			default : linebuf_SData <= #`D 8'hxx;
			endcase
		if(w_write_enable) begin
			r_capture_start  <= #`D (linebuf_MAddr[6:0] == 7'h10) ? linebuf_MData[0] : r_capture_start;
			r_line_addr[7:0] <= #`D (linebuf_MAddr[6:0] == 7'h20) ? linebuf_MData : r_line_addr[7:0];
			r_line_addr[8]   <= #`D (linebuf_MAddr[6:0] == 7'h21) ? linebuf_MData[0] : r_line_addr[8];
			r_line_size      <= #`D (linebuf_MAddr[6:0] == 7'h30) ? linebuf_MData[4:0] : r_line_size;
		end else begin
			r_capture_start  <= #`D w_kicked ? 1'b0 : r_capture_start;
		end
	end

// sync : writeClk to readClk
reg        r_capture_end;
syncd01a sync_capture_end (
	.clk     ( readClk ),
	.reset_n ( readRst_n ),
	.d       ( r_capture_end ),
	.q       ( w_capture_end )
);

syncd01a sync_kicked (
	.clk     ( readClk ),
	.reset_n ( readRst_n ),
	.d       ( r_kicked ),
	.q       ( w_kicked )
);


// sync : readClk to writeClk
wire       w_capture_start;
wire [8:0] w_line_addr;
wire [4:0] w_line_size;
syncd01a sync_capture_start (
	.clk     ( writeClk ),
	.reset_n ( writeRst_n ),
	.d       ( r_capture_start ),
	.q       ( w_capture_start )
);
syncd01a #9 sync_line_addr ( // bit skew ignored
	.clk     ( writeClk ),
	.reset_n ( writeRst_n ),
	.d       ( r_line_addr ),
	.q       ( w_line_addr )
);
syncd01a #5 sync_line_size ( // bit skew ignored
	.clk     ( writeClk ),
	.reset_n ( writeRst_n ),
	.d       ( r_line_size ),
	.q       ( w_line_size )
);


/***************************************
*             Camera inputs            *
***************************************/
reg r_VSYNC;
reg r_HREF_pre;
reg r_HREF;
reg [7:0] r_DATA_pre;
reg [7:0] r_DATA;

// retime inputs
always @ (posedge writeClk or negedge writeRst_n)
	if(~writeRst_n) begin
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
	.clk(writeClk),
	.reset_n(writeRst_n),
	.in(r_VSYNC),
	.trigger(w_frame_start)
);

/***************************************
*         Capture State machine        *
***************************************/
reg [3:0] r_cap_state;
wire w_capture_area;
parameter P_STATE_INIT  = 4'h0;
parameter P_STATE_WAIT0 = 4'h1;
parameter P_STATE_WAIT1 = 4'h2;

always @ (posedge writeClk or negedge writeRst_n)
	if(~writeRst_n) begin
		r_cap_state   <= #`D P_STATE_INIT;
		r_kicked      <= #`D 1'b0;
		r_capture_end <= #`D 1'b0;
	end else begin
		case(r_cap_state)
		P_STATE_INIT : begin
			if(w_capture_start & w_frame_start) begin
				r_cap_state   <= #`D P_STATE_WAIT0;
				r_kicked      <= #`D 1'b1;
				r_capture_end <= #`D 1'b0;
			end
		end
		P_STATE_WAIT0 : begin
			r_kicked <= #`D 1'b0;
			if(w_capture_area) 
				r_cap_state <= #`D P_STATE_WAIT1;
		end
		P_STATE_WAIT1 : begin
			if(~w_capture_area) begin
				r_cap_state   <= #`D P_STATE_INIT;
				r_capture_end <= #`D 1'b1;
			end
		end
		endcase
	end

reg [8:0] r_linecount;
reg       r_countup;
always @ (posedge writeClk or negedge writeRst_n)
	if(~writeRst_n) begin
		r_linecount <= #`D 9'h000;
		r_countup   <= #`D 1'b1;
	end else begin
		if(w_frame_start) begin
			r_linecount <= #`D 9'h000;
			r_countup   <= #`D 1'b0;
		end else if(r_HREF_pre) begin
			if(r_countup) begin
				r_linecount <= #`D r_linecount + 9'h1; 
				r_countup   <= #`D 1'b0;
			end
		end else begin
			r_countup <= #`D 1'b1;
		end
	end

assign w_capture_area = (r_linecount >= w_line_addr) & (r_linecount < w_line_addr + {4'h0, w_line_size});

/***************************************
*        Async FIFO : FPGA macro       *
* 32768 words, first word fall through *
***************************************/
wire       w_fifo_write_enable;
wire       w_full;
wire       w_overflow;
wire       w_fifo_read_enable;
assign w_fifo_read_enable  = w_read_enable & (linebuf_MAddr[6:0] == 7'h00);
assign w_fifo_write_enable = r_HREF & w_capture_area & (r_cap_state != P_STATE_INIT);

line_fifo line_fifo(
	.rst       ( ~writeRst_n ),
	.wr_clk    ( writeClk ),
	.din       ( r_DATA ),
	.wr_en     ( w_fifo_write_enable ),
	.full      ( w_full ),
	.overflow  ( w_overflow ),
	.rd_clk    ( readClk ),
	.dout      ( w_read_data ),
	.rd_en     ( w_fifo_read_enable ),
	.empty     ( w_fifo_status[2] ),
	.underflow ( w_fifo_status[3] )
);

syncd01a sync_flag_full(
	.clk     ( readClk ),
	.reset_n ( readRst_n ),
	.d       ( w_full ),
	.q       ( w_fifo_status[0] )
);
syncd01a sync_flag_overflow(
	.clk     ( readClk ),
	.reset_n ( readRst_n ),
	.d       ( w_overflow ),
	.q       ( w_fifo_status[1] )
);


endmodule


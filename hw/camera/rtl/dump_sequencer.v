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

/*
function [7:0] convert_ascii;
input [3:0] hex;
	if(hex < 4'ha) 
		convert_ascii = 8'h30+{4'h0,hex};
	else 
		convert_ascii = 8'h37+{4'h0,hex};
endfunction
*/

reg [3:0] dumper_state;
parameter P_STATE_INIT           = 4'd0;
parameter P_STATE_START          = 4'd1;
parameter P_STATE_READMEM        = 4'd2;
parameter P_STATE_CONVERT_RGB565 = 4'd3;
parameter P_STATE_DUMP0          = 4'd4;
parameter P_STATE_DUMP1          = 4'd5;
parameter P_STATE_END            = 4'd6;
parameter P_STATE_HDUMP0         = 4'd7;
parameter P_STATE_HDUMP1         = 4'd8;

reg        dump_done;
reg        s1_OE;
reg [17:0] s1_Addr;
reg [31:0] data_buffer;
reg        rs_tx_start;
reg  [7:0] rs_tx_data;
integer i;
reg  [3:0] send_ptr;
reg  [7:0] send_data[0:11];

reg  [5:0] header_ptr;

wire [7:0] bmp_header[0:53];
assign bmp_header[ 0] = 8'h42; // bfType
assign bmp_header[ 1] = 8'h4d; // bfType
assign bmp_header[ 2] = 8'he6; // bfSize
assign bmp_header[ 3] = 8'hdf; // bfSize
assign bmp_header[ 4] = 8'h01; // bfSize
assign bmp_header[ 5] = 8'h00; // bfSize
assign bmp_header[ 6] = 8'h00; // bfReserved1
assign bmp_header[ 7] = 8'h00; // bfReserved1
assign bmp_header[ 8] = 8'h00; // bfReserved2
assign bmp_header[ 9] = 8'h00; // bfReserved2
assign bmp_header[10] = 8'h36; // bfOffset
assign bmp_header[11] = 8'h00; // bfOffset
assign bmp_header[12] = 8'h00; // bfOffset
assign bmp_header[13] = 8'h00; // bfOffset
assign bmp_header[14] = 8'h28; // biSize
assign bmp_header[15] = 8'h00; // biSize
assign bmp_header[16] = 8'h00; // biSize
assign bmp_header[17] = 8'h00; // biSize
assign bmp_header[18] = 8'h80; // biWidth
assign bmp_header[19] = 8'h02; // biWidth
assign bmp_header[20] = 8'h00; // biWidth
assign bmp_header[21] = 8'h00; // biWidth
assign bmp_header[22] = 8'he0; // biHeight
assign bmp_header[23] = 8'h01; // biHeight
assign bmp_header[24] = 8'h00; // biHeight
assign bmp_header[25] = 8'h00; // biHeight
assign bmp_header[26] = 8'h01; // biPlanes
assign bmp_header[27] = 8'h00; // biPlanes
assign bmp_header[28] = 8'h20; // biBitCount
assign bmp_header[29] = 8'h00; // biBitCount
assign bmp_header[30] = 8'h00; // biCompression
assign bmp_header[31] = 8'h00; // biCompression
assign bmp_header[32] = 8'h00; // biCompression
assign bmp_header[33] = 8'h00; // biCompression
assign bmp_header[34] = 8'h00; // biSizeImage
assign bmp_header[35] = 8'h00; // biSizeImage
assign bmp_header[36] = 8'h00; // biSizeImage
assign bmp_header[37] = 8'h00; // biSizeImage
assign bmp_header[38] = 8'h00; // biXPixPerMeter
assign bmp_header[39] = 8'h00; // biXPixPerMeter
assign bmp_header[40] = 8'h00; // biXPixPerMeter
assign bmp_header[41] = 8'h00; // biXPixPerMeter
assign bmp_header[42] = 8'h00; // biYPixPerMeter
assign bmp_header[43] = 8'h00; // biYPixPerMeter
assign bmp_header[44] = 8'h00; // biYPixPerMeter
assign bmp_header[45] = 8'h00; // biYPixPerMeter
assign bmp_header[46] = 8'h00; // biClrUsed
assign bmp_header[47] = 8'h00; // biClrUsed
assign bmp_header[48] = 8'h00; // biClrUsed
assign bmp_header[49] = 8'h00; // biClrUsed
assign bmp_header[50] = 8'h00; // biClrImportant
assign bmp_header[51] = 8'h00; // biClrImportant
assign bmp_header[52] = 8'h00; // biClrImportant
assign bmp_header[53] = 8'h00; // biClrImportant


always @ (posedge clk or negedge reset_n)
	if(~reset_n) begin
		dumper_state <= P_STATE_INIT;
		dump_done    <= 1'b0;
		s1_OE        <= 1'b1;
		s1_Addr      <= 18'h3ffff;
		data_buffer  <= 32'h0;
		rs_tx_start  <= 1'b0;
		rs_tx_data   <= 8'h00;
		for(i=0; i<8; i=i+1) begin
			send_data[i] <= 8'h00;
		end
		send_ptr     <= 4'h0;
		header_ptr   <= 6'h00;
	end else begin
		case(dumper_state) 
			P_STATE_INIT: begin
				if(dump_kick_sync) 
					dumper_state <= P_STATE_HDUMP0;
			end
			P_STATE_HDUMP0 : begin
				if(header_ptr == 6'd54) begin
					header_ptr     <= 4'h0;
					dumper_state <= P_STATE_START;
				end else begin
					if(~rs_tx_status) begin
						rs_tx_start  <= 1'b1;
						rs_tx_data   <= bmp_header[header_ptr];
						header_ptr   <= header_ptr + 6'h1;
						dumper_state <= P_STATE_HDUMP1;
					end
				end
			end
			P_STATE_HDUMP1 : begin
				rs_tx_start  <= 1'b0;
				dumper_state <= P_STATE_HDUMP0;
			end
			P_STATE_START: begin
				if((s1_Addr != 18'h3ffff) & (s1_Addr >= last_addr)) begin
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
				dumper_state <= P_STATE_CONVERT_RGB565;
			end
			P_STATE_CONVERT_RGB565 : begin
				send_data[0]  <= {data_buffer[7:3],   3'b000};                    // blue  0
				send_data[1]  <= {data_buffer[2:0],   data_buffer[15:13], 2'b00}; // green 0
				send_data[2]  <= {data_buffer[12:8],  3'b000};                    // red   0
				send_data[3]  <= 8'h00;
				send_data[4]  <= {data_buffer[23:19], 3'b000};                    // blue  1
				send_data[5]  <= {data_buffer[18:16], data_buffer[31:29], 2'b00}; // green 1
				send_data[6]  <= {data_buffer[28:24], 3'b000};                    // red   1
				send_data[7]  <= 8'h00;
				dumper_state  <= P_STATE_DUMP0;
			end
			P_STATE_DUMP0 : begin
				if(send_ptr == 4'd8) begin
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

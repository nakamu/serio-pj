`timescale 1ns/1ps

module sound_sequencer(
	baseclk,
	asyncrst_n,
	rom_addr,
	rom_data,
	octave,
	note,
	duty,
	mode
);

parameter NCH = 4;

input                baseclk;
input                asyncrst_n;
output        [12:0] rom_addr;
input         [15:0] rom_data;
output [(NCH)*3-1:0] octave;
output [(NCH)*4-1:0] note;
output [(NCH)*4-1:0] duty;
output [(NCH)*2-1:0] mode;

/*----------------------------------------------------------------------
	tick(count)                : 16'b0000xxxx_cccccccc
	set_tick(ms)               : 16'b0001xxxx_tttttttt
		div = 25000 * tick = 16384 + 8616 = 16384 + 8192 + 424 
		    = 16384 + 8192 + 256 + 168 = 16384 + 8192 + 256 + 128 + 40
			= 16384 + 8192 + 256 + 128 + 32 + 8
			= 2^14 + 2^13 + 2^8 + 2^7 + 2^5 + 2^3
	set_mode(ch, mode)         : 16'b0010cccc_xxxxxxmm
	set_duty(ch, duty)         : 16'b0011cccc_xxxxdddd
	set_note(ch, octave, note) : 16'b0100cccc_xooonnnn
	halt                       : 16'b1111xxxx_xxxxxxxx
-----------------------------------------------------------------------*/

reg         [7:0] tick;
reg         [7:0] wait_cycle;
reg         [2:0] reg_octave [0:NCH-1];
reg         [3:0] reg_note   [0:NCH-1];
reg         [3:0] reg_duty   [0:NCH-1];
reg         [1:0] reg_mode   [0:NCH-1];

genvar i;
generate for(i = 0; i < NCH; i = i + 1) begin : assign_vector
	assign octave[3*(i+1)-1:3*i] = reg_octave[i];
	assign note  [4*(i+1)-1:4*i] = reg_note[i];
	assign duty  [4*(i+1)-1:4*i] = reg_duty[i];
	assign mode  [2*(i+1)-1:2*i] = reg_mode[i];
end
endgenerate

reg [22:0] divide;
reg [22:0] timecounter;
wire       tick_expired;
assign tick_expired = (timecounter == divide); 

always @ (posedge baseclk or negedge asyncrst_n)
	if(~asyncrst_n) begin
		divide <= 23'h1;
	end else begin
		divide <= {1'b0, tick, 14'b0} + {2'b00, tick, 13'b0} + {7'b0, tick, 8'b0} + {8'b0, tick, 7'b0} + {10'b0, tick, 5'b0} + {12'b0, tick, 3'b0};
	end

always @ (posedge baseclk or negedge asyncrst_n)
	if(~asyncrst_n) begin
		timecounter <= 23'h1;
	end else begin
		timecounter <= tick_expired ? 23'h1 : timecounter + 23'h1;
	end

parameter ST_HALT = 2'b00;
parameter ST_READ = 2'b01;
parameter ST_EXEC = 2'b10;
parameter ST_WAIT = 2'b11;
reg  [1:0] state;
reg [12:0] rom_addr;
reg [15:0] wait_count;

wire [3:0] romcmd_cmd;
wire [3:0] romcmd_ch;
assign romcmd_cmd = rom_data[15:12];
assign romcmd_ch  = rom_data[11:8];

wire [1:0] ch_select_2bit_msb;

integer j;
always @ (posedge baseclk or negedge asyncrst_n)
	if(~asyncrst_n) begin
		state      <= ST_READ;
		rom_addr   <= 13'h0;
		tick       <= 8'h0;
		wait_cycle <= 8'h1;
		wait_count <= 8'h1;
		for(j = 0; j < NCH; j = j + 1) begin
			reg_mode[j]       <= 2'b00;
			reg_duty[j]       <= 4'b0000;
			reg_octave[j]     <= 3'b000;
			reg_note[j]       <= 4'b0000;
		end
	end else begin
		case(state) 
		ST_HALT : begin
			tick       <= 8'h0;
			wait_cycle <= 8'h0;
			for(j = 0; j < NCH; j = j + 1) begin
				reg_mode[j]       <= 2'b00;
				reg_duty[j]       <= 4'b0000;
				reg_octave[j]     <= 3'b000;
				reg_note[j]       <= 4'b0000;
			end
		end
		ST_READ : begin
			state <= ST_EXEC;
		end
		ST_EXEC : begin
			case(romcmd_cmd)
				4'b0000 : begin // tick
					if(rom_data[7:0] == 8'h00) begin
						wait_cycle <= 8'h1;
					end else begin
						wait_cycle <= rom_data[7:0];
					end
					state      <= ST_WAIT;
				end
				4'b0001 : begin // set_tick
					tick       <= rom_data[7:0];
					state      <= ST_READ;
				end
				4'b0010 : begin // set_mode
					if(romcmd_ch < NCH) begin
						reg_mode[romcmd_ch] <= rom_data[1:0];
					end
					state      <= ST_READ;
				end
				4'b0011 : begin // set_duty
					if(romcmd_ch < NCH) begin
						reg_duty[romcmd_ch] <= rom_data[3:0];
					end
					state      <= ST_READ;
				end
				4'b0100 : begin // set_note
					if(romcmd_ch < NCH) begin
						reg_octave[romcmd_ch] <= rom_data[6:4];
						reg_note[romcmd_ch]   <= rom_data[3:0];
					end
					state      <= ST_READ;
				end
				4'b1111 : begin // halt
					state      <= ST_HALT;
				end
				default : begin // undefined
					state      <= ST_READ;
				end
			endcase
			rom_addr <= rom_addr + 13'h1;
		end
		ST_WAIT : begin
			if(tick_expired) begin
				if(wait_count == wait_cycle) begin
					wait_count <= 8'h1;
					state      <= ST_READ;
					rom_addr   <= rom_addr + 13'h1;
				end else begin
					wait_count <= wait_count + 8'h1;
				end
			end
		end	
		default : begin
			state <= ST_HALT;
		end
		endcase
	end

endmodule


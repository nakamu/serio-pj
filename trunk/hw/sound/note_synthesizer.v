`timescale 1ns/1ps

// this module requires 25MHz baseclk

module note_synthesizer(baseclk, asyncrst_n, octave, note, duty, effect, waveout);
input       baseclk;
input       asyncrst_n;
input [2:0] octave;
input [3:0] note;
input [3:0] duty;
input [1:0] effect;

output waveout;
reg    waveout;
reg    normal_out;
reg    duty_out;
wire   prbs_out;

parameter EFFECT_MUTE = 2'b00;
parameter EFFECT_NONE = 2'b01;
parameter EFFECT_DUTY = 2'b10;
parameter EFFECT_PRBS = 2'b11;

always @ *
	case(effect)
	EFFECT_MUTE: waveout = 1'b0;
	EFFECT_NONE: waveout = normal_out;
	EFFECT_DUTY: waveout = duty_out;
	EFFECT_PRBS: waveout = prbs_out | normal_out;
	endcase

//---------------------------------------
//  base counter (16 bit) 
//---------------------------------------
reg [15:0] divide;
reg [15:0] counter;
wire   divided_pulse;
assign divided_pulse = (counter == divide);

always @ (posedge baseclk or negedge asyncrst_n)
	if(~asyncrst_n) begin
		counter <= 16'h1;
	end else begin
		counter <= divided_pulse ? 16'h1 : counter + 16'h1;
	end

reg [3:0] ptr;
always @ (posedge baseclk or negedge asyncrst_n)
	if(~asyncrst_n) begin
		ptr        <= 4'h0;
		normal_out <= 1'b0; 
	end else begin
		if(divided_pulse) begin
			ptr        <= ptr + 4'h1;
			normal_out <= ptr[3];
			duty_out   <= (duty >= ptr);
		end
	end

//---------------------------------------
//  PRBS (Galois LFSR)
//---------------------------------------
reg [15:0] prbs;
parameter PRBS_INIT = 16'b1010_1100_1110_0001;
always @ (posedge baseclk or negedge asyncrst_n)
	if(~asyncrst_n) prbs <= PRBS_INIT;
	else            prbs <= {prbs[0],            prbs[15], 
		                     prbs[0] ^ prbs[14], prbs[0] ^ prbs[13], 
		                     prbs[12],           prbs[0] ^ prbs[11], 
		                     prbs[10:1]};
assign prbs_out = prbs[0];

//---------------------------------------
//  Frequency divider setting (LUT)
//---------------------------------------
always @ (posedge baseclk or negedge asyncrst_n)
	if(~asyncrst_n) begin
		divide <= 15'd10;
	end else begin
		divide <= divider_table(octave, note);
	end

function [15:0] divider_table;
input [2:0] f_octave;
input [3:0] f_note;

case({f_octave, f_note})
	 { 3'd0, 4'd0  } : divider_table = 16'd48828;
	 { 3'd0, 4'd1  } : divider_table = 16'd46088;
	 { 3'd0, 4'd2  } : divider_table = 16'd43501;
	 { 3'd0, 4'd3  } : divider_table = 16'd41059;
	 { 3'd0, 4'd4  } : divider_table = 16'd38755;
	 { 3'd0, 4'd5  } : divider_table = 16'd36580;
	 { 3'd0, 4'd6  } : divider_table = 16'd34527;
	 { 3'd0, 4'd7  } : divider_table = 16'd32589;
	 { 3'd0, 4'd8  } : divider_table = 16'd30760;
	 { 3'd0, 4'd9  } : divider_table = 16'd29033;
	 { 3'd0, 4'd10 } : divider_table = 16'd27404;
	 { 3'd0, 4'd11 } : divider_table = 16'd25866;
	 { 3'd1, 4'd0  } : divider_table = 16'd24414;
	 { 3'd1, 4'd1  } : divider_table = 16'd23044;
	 { 3'd1, 4'd2  } : divider_table = 16'd21750;
	 { 3'd1, 4'd3  } : divider_table = 16'd20530;
	 { 3'd1, 4'd4  } : divider_table = 16'd19377;
	 { 3'd1, 4'd5  } : divider_table = 16'd18290;
	 { 3'd1, 4'd6  } : divider_table = 16'd17263;
	 { 3'd1, 4'd7  } : divider_table = 16'd16294;
	 { 3'd1, 4'd8  } : divider_table = 16'd15380;
	 { 3'd1, 4'd9  } : divider_table = 16'd14517;
	 { 3'd1, 4'd10 } : divider_table = 16'd13702;
	 { 3'd1, 4'd11 } : divider_table = 16'd12933;
	 { 3'd2, 4'd0  } : divider_table = 16'd12207;
	 { 3'd2, 4'd1  } : divider_table = 16'd11522;
	 { 3'd2, 4'd2  } : divider_table = 16'd10875;
	 { 3'd2, 4'd3  } : divider_table = 16'd10265;
	 { 3'd2, 4'd4  } : divider_table = 16'd9689;
	 { 3'd2, 4'd5  } : divider_table = 16'd9145;
	 { 3'd2, 4'd6  } : divider_table = 16'd8632;
	 { 3'd2, 4'd7  } : divider_table = 16'd8147;
	 { 3'd2, 4'd8  } : divider_table = 16'd7690;
	 { 3'd2, 4'd9  } : divider_table = 16'd7258;
	 { 3'd2, 4'd10 } : divider_table = 16'd6851;
	 { 3'd2, 4'd11 } : divider_table = 16'd6466;
	 { 3'd3, 4'd0  } : divider_table = 16'd6104;
	 { 3'd3, 4'd1  } : divider_table = 16'd5761;
	 { 3'd3, 4'd2  } : divider_table = 16'd5438;
	 { 3'd3, 4'd3  } : divider_table = 16'd5132;
	 { 3'd3, 4'd4  } : divider_table = 16'd4844;
	 { 3'd3, 4'd5  } : divider_table = 16'd4572;
	 { 3'd3, 4'd6  } : divider_table = 16'd4316;
	 { 3'd3, 4'd7  } : divider_table = 16'd4074;
	 { 3'd3, 4'd8  } : divider_table = 16'd3845;
	 { 3'd3, 4'd9  } : divider_table = 16'd3629;
	 { 3'd3, 4'd10 } : divider_table = 16'd3425;
	 { 3'd3, 4'd11 } : divider_table = 16'd3233;
	 { 3'd4, 4'd0  } : divider_table = 16'd3052;
	 { 3'd4, 4'd1  } : divider_table = 16'd2880;
	 { 3'd4, 4'd2  } : divider_table = 16'd2719;
	 { 3'd4, 4'd3  } : divider_table = 16'd2566;
	 { 3'd4, 4'd4  } : divider_table = 16'd2422;
	 { 3'd4, 4'd5  } : divider_table = 16'd2286;
	 { 3'd4, 4'd6  } : divider_table = 16'd2158;
	 { 3'd4, 4'd7  } : divider_table = 16'd2037;
	 { 3'd4, 4'd8  } : divider_table = 16'd1922;
	 { 3'd4, 4'd9  } : divider_table = 16'd1815;
	 { 3'd4, 4'd10 } : divider_table = 16'd1713;
	 { 3'd4, 4'd11 } : divider_table = 16'd1617;
	 { 3'd5, 4'd0  } : divider_table = 16'd1526;
	 { 3'd5, 4'd1  } : divider_table = 16'd1440;
	 { 3'd5, 4'd2  } : divider_table = 16'd1359;
	 { 3'd5, 4'd3  } : divider_table = 16'd1283;
	 { 3'd5, 4'd4  } : divider_table = 16'd1211;
	 { 3'd5, 4'd5  } : divider_table = 16'd1143;
	 { 3'd5, 4'd6  } : divider_table = 16'd1079;
	 { 3'd5, 4'd7  } : divider_table = 16'd1018;
	 { 3'd5, 4'd8  } : divider_table = 16'd961;
	 { 3'd5, 4'd9  } : divider_table = 16'd907;
	 { 3'd5, 4'd10 } : divider_table = 16'd856;
	 { 3'd5, 4'd11 } : divider_table = 16'd808;
	 { 3'd6, 4'd0  } : divider_table = 16'd763;
	 { 3'd6, 4'd1  } : divider_table = 16'd720;
	 { 3'd6, 4'd2  } : divider_table = 16'd680;
	 { 3'd6, 4'd3  } : divider_table = 16'd642;
	 { 3'd6, 4'd4  } : divider_table = 16'd606;
	 { 3'd6, 4'd5  } : divider_table = 16'd572;
	 { 3'd6, 4'd6  } : divider_table = 16'd539;
	 { 3'd6, 4'd7  } : divider_table = 16'd509;
	 { 3'd6, 4'd8  } : divider_table = 16'd481;
	 { 3'd6, 4'd9  } : divider_table = 16'd454;
	 { 3'd6, 4'd10 } : divider_table = 16'd428;
	 { 3'd6, 4'd11 } : divider_table = 16'd404;
	 { 3'd7, 4'd0  } : divider_table = 16'd381;
	 { 3'd7, 4'd1  } : divider_table = 16'd360;
	 { 3'd7, 4'd2  } : divider_table = 16'd340;
	 { 3'd7, 4'd3  } : divider_table = 16'd321;
	 { 3'd7, 4'd4  } : divider_table = 16'd303;
	 { 3'd7, 4'd5  } : divider_table = 16'd286;
	 { 3'd7, 4'd6  } : divider_table = 16'd270;
	 { 3'd7, 4'd7  } : divider_table = 16'd255;
	 { 3'd7, 4'd8  } : divider_table = 16'd240;
	 { 3'd7, 4'd9  } : divider_table = 16'd227;
	 { 3'd7, 4'd10 } : divider_table = 16'd214;
	 { 3'd7, 4'd11 } : divider_table = 16'd202;
	 default         : divider_table = 16'd10;
	endcase
endfunction

endmodule

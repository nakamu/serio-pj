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
	{3'd0, 4'd0}  : divider_table = 16'd47778;
	{3'd0, 4'd1}  : divider_table = 16'd45097;
	{3'd0, 4'd2}  : divider_table = 16'd42566;
	{3'd0, 4'd3}  : divider_table = 16'd40177;
	{3'd0, 4'd4}  : divider_table = 16'd37922;
	{3'd0, 4'd5}  : divider_table = 16'd35793;
	{3'd0, 4'd6}  : divider_table = 16'd33784;
	{3'd0, 4'd7}  : divider_table = 16'd31888;
	{3'd0, 4'd8}  : divider_table = 16'd30098;
	{3'd0, 4'd9}  : divider_table = 16'd28409;
	{3'd0, 4'd10} : divider_table = 16'd26815;
	{3'd0, 4'd11} : divider_table = 16'd25310;
	{3'd1, 4'd0}  : divider_table = 16'd23889;
	{3'd1, 4'd1}  : divider_table = 16'd22548;
	{3'd1, 4'd2}  : divider_table = 16'd21283;
	{3'd1, 4'd3}  : divider_table = 16'd20088;
	{3'd1, 4'd4}  : divider_table = 16'd18961;
	{3'd1, 4'd5}  : divider_table = 16'd17897;
	{3'd1, 4'd6}  : divider_table = 16'd16892;
	{3'd1, 4'd7}  : divider_table = 16'd15944;
	{3'd1, 4'd8}  : divider_table = 16'd15049;
	{3'd1, 4'd9}  : divider_table = 16'd14205;
	{3'd1, 4'd10} : divider_table = 16'd13407;
	{3'd1, 4'd11} : divider_table = 16'd12655;
	{3'd2, 4'd0}  : divider_table = 16'd11945;
	{3'd2, 4'd1}  : divider_table = 16'd11274;
	{3'd2, 4'd2}  : divider_table = 16'd10641;
	{3'd2, 4'd3}  : divider_table = 16'd10044;
	{3'd2, 4'd4}  : divider_table = 16'd9480;
	{3'd2, 4'd5}  : divider_table = 16'd8948;
	{3'd2, 4'd6}  : divider_table = 16'd8446;
	{3'd2, 4'd7}  : divider_table = 16'd7972;
	{3'd2, 4'd8}  : divider_table = 16'd7525;
	{3'd2, 4'd9}  : divider_table = 16'd7102;
	{3'd2, 4'd10} : divider_table = 16'd6704;
	{3'd2, 4'd11} : divider_table = 16'd6327;
	{3'd3, 4'd0}  : divider_table = 16'd5972;
	{3'd3, 4'd1}  : divider_table = 16'd5637;
	{3'd3, 4'd2}  : divider_table = 16'd5321;
	{3'd3, 4'd3}  : divider_table = 16'd5022;
	{3'd3, 4'd4}  : divider_table = 16'd4740;
	{3'd3, 4'd5}  : divider_table = 16'd4474;
	{3'd3, 4'd6}  : divider_table = 16'd4223;
	{3'd3, 4'd7}  : divider_table = 16'd3986;
	{3'd3, 4'd8}  : divider_table = 16'd3762;
	{3'd3, 4'd9}  : divider_table = 16'd3551;
	{3'd3, 4'd10} : divider_table = 16'd3352;
	{3'd3, 4'd11} : divider_table = 16'd3164;
	{3'd4, 4'd0}  : divider_table = 16'd2986;
	{3'd4, 4'd1}  : divider_table = 16'd2819;
	{3'd4, 4'd2}  : divider_table = 16'd2660;
	{3'd4, 4'd3}  : divider_table = 16'd2511;
	{3'd4, 4'd4}  : divider_table = 16'd2370;
	{3'd4, 4'd5}  : divider_table = 16'd2237;
	{3'd4, 4'd6}  : divider_table = 16'd2112;
	{3'd4, 4'd7}  : divider_table = 16'd1993;
	{3'd4, 4'd8}  : divider_table = 16'd1881;
	{3'd4, 4'd9}  : divider_table = 16'd1776;
	{3'd4, 4'd10} : divider_table = 16'd1676;
	{3'd4, 4'd11} : divider_table = 16'd1582;
	{3'd5, 4'd0}  : divider_table = 16'd1493;
	{3'd5, 4'd1}  : divider_table = 16'd1409;
	{3'd5, 4'd2}  : divider_table = 16'd1330;
	{3'd5, 4'd3}  : divider_table = 16'd1256;
	{3'd5, 4'd4}  : divider_table = 16'd1185;
	{3'd5, 4'd5}  : divider_table = 16'd1119;
	{3'd5, 4'd6}  : divider_table = 16'd1056;
	{3'd5, 4'd7}  : divider_table = 16'd997;
	{3'd5, 4'd8}  : divider_table = 16'd941;
	{3'd5, 4'd9}  : divider_table = 16'd888;
	{3'd5, 4'd10} : divider_table = 16'd838;
	{3'd5, 4'd11} : divider_table = 16'd791;
	{3'd6, 4'd0}  : divider_table = 16'd747;
	{3'd6, 4'd1}  : divider_table = 16'd705;
	{3'd6, 4'd2}  : divider_table = 16'd665;
	{3'd6, 4'd3}  : divider_table = 16'd628;
	{3'd6, 4'd4}  : divider_table = 16'd593;
	{3'd6, 4'd5}  : divider_table = 16'd559;
	{3'd6, 4'd6}  : divider_table = 16'd528;
	{3'd6, 4'd7}  : divider_table = 16'd498;
	{3'd6, 4'd8}  : divider_table = 16'd470;
	{3'd6, 4'd9}  : divider_table = 16'd444;
	{3'd6, 4'd10} : divider_table = 16'd419;
	{3'd6, 4'd11} : divider_table = 16'd395;
	{3'd7, 4'd0}  : divider_table = 16'd373;
	{3'd7, 4'd1}  : divider_table = 16'd352;
	{3'd7, 4'd2}  : divider_table = 16'd333;
	{3'd7, 4'd3}  : divider_table = 16'd314;
	{3'd7, 4'd4}  : divider_table = 16'd296;
	{3'd7, 4'd5}  : divider_table = 16'd280;
	{3'd7, 4'd6}  : divider_table = 16'd264;
	{3'd7, 4'd7}  : divider_table = 16'd249;
	{3'd7, 4'd8}  : divider_table = 16'd235;
	{3'd7, 4'd9}  : divider_table = 16'd222;
	{3'd7, 4'd10} : divider_table = 16'd209;
	{3'd7, 4'd11} : divider_table = 16'd198;
	 default      : divider_table = 16'd10;
	endcase
endfunction

endmodule

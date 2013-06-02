`timescale 1ns/1ps

module synthesizer(xclkin, reset_n, buzzerout);
input       xclkin;     // P83
input       reset_n;    // P85
output      buzzerout; // synthesized buzzer sound !

wire baseclk;
wire asyncrst_n;

wire [2:0] octave0;
wire [3:0] note0;
wire [3:0] duty0;
wire [1:0] mode0;
wire       waveout0;
wire [2:0] octave1;
wire [3:0] note1;
wire [3:0] duty1;
wire [1:0] mode1;
wire       waveout1;
wire [2:0] octave2;
wire [3:0] note2;
wire [3:0] duty2;
wire [1:0] mode2;
wire       waveout2;
wire [2:0] octave3;
wire [3:0] note3;
wire [3:0] duty3;
wire [1:0] mode3;
wire       waveout3;

wire [15:0] rom_addr;
wire [12:0] rom_data;

clock_reset clock_reset(
	.xclkin     ( xclkin     ) ,
	.reset_n    ( reset_n    ) ,
	.baseclk    ( baseclk    ) ,
	.asyncrst_n ( asyncrst_n ) 
);

blk_mem_gen_v7_3 sequence_rom(
	.clka    (  baseclk    ) ,
//	.rsta    ( ~asyncrst_n ) ,
	.addra   ( rom_addr    ) ,
	.douta   ( rom_data    )
);

sound_sequencer #(.NCH(4'd4)) sound_sequencer(
	.baseclk    ( baseclk    ) ,
	.asyncrst_n ( asyncrst_n ) ,
	.rom_addr   ( rom_addr   ) ,
	.rom_data   ( rom_data   ) ,
	.octave     ( {octave3, octave2, octave1, octave0} ) ,
	.note       ( {note3, note2, note1, note0} ) ,
	.duty       ( {duty3, duty2, duty1, duty0} ) ,
	.mode       ( {mode3, mode2, mode1, mode0} )
);

note_synthesizer note_synth0(baseclk, asyncrst_n, octave0, note0, duty0, mode0, waveout0);
note_synthesizer note_synth1(baseclk, asyncrst_n, octave1, note1, duty1, mode1, waveout1);
note_synthesizer note_synth2(baseclk, asyncrst_n, octave2, note2, duty2, mode2, waveout2);
note_synthesizer note_synth3(baseclk, asyncrst_n, octave3, note3, duty3, mode3, waveout3);

assign buzzerout = waveout0 | waveout1 | waveout2 | waveout3;

endmodule

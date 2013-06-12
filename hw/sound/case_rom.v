`timescale 1ns/1ps
module case_rom(clk, asyncrst_n, addr, data);
input         clk;
input         asyncrst_n;
input  [12:0] addr;
output [15:0] data;

reg    [15:0] data;

always @ (posedge clk or negedge asyncrst_n)
	if(~asyncrst_n) data <= 16'h0000;
	else            data <= rom_data(addr);

function [15:0] rom_data;
input [12:0] address;
	case(address)	
		13'h0000 : rom_data = 16'h1032;
		13'h0001 : rom_data = 16'h0002;
		13'h0002 : rom_data = 16'h2001;
		13'h0003 : rom_data = 16'h2100;
		13'h0004 : rom_data = 16'h2200;
		13'h0005 : rom_data = 16'h2300;
		13'h0006 : rom_data = 16'h3007;
		13'h0007 : rom_data = 16'h3108;
		13'h0008 : rom_data = 16'h3209;
		13'h0009 : rom_data = 16'h330a;
		13'h000a : rom_data = 16'h4020;
		13'h000b : rom_data = 16'h0004;
		13'h000c : rom_data = 16'h4022;
		13'h000d : rom_data = 16'h0004;
		13'h000e : rom_data = 16'h4024;
		13'h000f : rom_data = 16'h0004;
		13'h0010 : rom_data = 16'h4025;
		13'h0011 : rom_data = 16'h0004;
		13'h0012 : rom_data = 16'h4027;
		13'h0013 : rom_data = 16'h0004;
		13'h0014 : rom_data = 16'h4029;
		13'h0015 : rom_data = 16'h0004;
		13'h0016 : rom_data = 16'h4031;
		13'h0017 : rom_data = 16'h0004;
		13'h0018 : rom_data = 16'h4030;
		13'h0019 : rom_data = 16'h0004;
		13'h001a : rom_data = 16'h4032;
		13'h001b : rom_data = 16'h0004;
		13'h001c : rom_data = 16'h4034;
		13'h001d : rom_data = 16'h0004;
		13'h001e : rom_data = 16'h4035;
		13'h001f : rom_data = 16'h0004;
		13'h0020 : rom_data = 16'h4037;
		13'h0021 : rom_data = 16'h0004;
		13'h0022 : rom_data = 16'h4039;
		13'h0023 : rom_data = 16'h0004;
		13'h0024 : rom_data = 16'h4031;
		13'h0025 : rom_data = 16'h0004;
		13'h0026 : rom_data = 16'h4030;
		13'h0027 : rom_data = 16'h0004;
		13'h0028 : rom_data = 16'hf000;
		default  : rom_data = 16'hffff;
	endcase
endfunction
endmodule

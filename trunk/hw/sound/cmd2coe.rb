#!/usr/bin/env ruby
#

def decode_cmd!(str)
	bin = 0x0
	str.gsub!(/,/, '')
	array = str.split(/\s+/)
	case array[0]
	when 'tick'
		if(array[1].nil?) then
			bin = 0x1 # tick 1 cycle
		else
			bin = array[1].to_i
		end
	when 'set_tick'
		if(array[1].nil?) then
			raise "Command Error : set_tick must have argument\n"
		end
		bin = 0x1000 | array[1].to_i
	when 'set_mode'
		if(array[1].nil? or array[2].nil?) then
			raise "Command Error : set_mode must have 2 arguments"
		end
		array[1].sub!(/ch/, '')
		ch = array[1].to_i
		mode = 0x0
		if   (array[2] == 'mute') then
			mode = 0x0
		elsif(array[2] == 'normal') then
			mode = 0x1
		elsif(array[2] == 'duty') then
			mode = 0x2
		elsif(array[2] == 'prbs') then
			mode = 0x3
		else
			raise "Syntax Error : #{str}\n"
		end
		bin = 0x2000 | ch << 8 | mode
	when 'set_duty'
		if(array[1].nil? or array[2].nil?) then
			raise "Command Error : set_duty must have 2 arguments"
		end
		array[1].sub!(/ch/, '')
		ch = array[1].to_i
		bin = 0x3000 | ch << 8 | array[2].to_i	
	when 'set_note'
		if(array[1].nil? or array[2].nil? or array[3].nil?) then
			raise "Command Error : set_note must have 3 arguments"
		end
		array[1].sub!(/ch/, '')
		ch = array[1].to_i
		sharp = 0
		flat  = 0
		if(array[3] =~ /#/) then
			sharp = 1
			array[3].gsub!('#', '')
		end
		if(array[3] =~ /b/) then
			flat = 1
			array[3].gsub!('b', '')
		end
		case array[3]
			when 'C'
				note = 0x0
			when 'D'
				note = 0x2
			when 'E'
				note = 0x4
			when 'F'
				note = 0x5
			when 'G'
				note = 0x7
			when 'A'
				note = 0x9
			when 'B'
				note = 0x11
			else 
				note = 0x0
				raise "Unknown note #{note}\n"
		end
		note += 1 if sharp
		note -= 1 if flat
		bin = 0x4000 | ch << 8 | array[2].to_i << 4 | note
	when 'halt'
		bin = 0xf000
	else
		# do nothing
	end
	return sprintf("%04x", bin)
end

def write_coe_header(fptr, cmd)
	fptr.write("; Sound Sequence from #{cmd}\n")
	fptr.write("memory_initialization_radix=16;\n")
	fptr.write("memory_initialization_vector=\n")
end

def write_case_header(fptr)
	header = <<EOS
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
EOS
	fptr.write(header)
end

def write_case_body(fpout, fpcmd)
	address = 0x0
	while line = fpcmd.gets
		next if(line =~ /^\s*#/)
		next if(line =~ /^\s*$/)
		decstr = decode_cmd!(line)
		outstr = sprintf("\t\t13'h%04x : rom_data = 16'h%s;\n", address, decstr)
		fpout.write(outstr)
		address += 1
	end
	fpout.write("\t\tdefault  : rom_data = 16'hffff;\n")
	fpout.write("\tendcase\n")
	fpout.write("endfunction\n")
	fpout.write("endmodule\n")
end

def write_coe_body(fpout, fpcmd)
	first_line = 1
	while line = fpcmd.gets
		next if(line =~ /^\s*#/)
		next if(line =~ /^\s*$/)
		if(first_line == 0) then
			fpout.write(",\n")
		else
			first_line = 0
		end
		decstr = decode_cmd!(line)
		fpout.write(decstr)
	end
	fpout.write(";\n")
end

#------------------------------------------------------------------
cmd  = ARGV[0]
raise "No input" if(cmd.nil?)
mode = ARGV[1]
if(mode.nil?) then
	print "mode default : verilog case\n"
	mode = 'verilog'
else 
	case mode
	when 'verilog', 'coe' 
		print "setting mode : #{mode}\n"
	else
		raise "unknown mode : #{mode}\n"
	end
end

unless(File.exists?(cmd)) then
	raise "Command file #{cmd} does not exist\n"
end

if(File.basename(cmd) =~ /(\w+)\.cmd$/) then
	coe = "#{$1}.coe"
end

fpcmd = File.open(cmd, "r")
if(mode == 'verilog') then
	fpout = File.open("case_rom.v", "w")
	write_case_header(fpout)
	write_case_body(fpout, fpcmd)
elsif(mode == 'coe') then
	fpout = File.open(coe, "w")
	write_coe_header(fpout, cmd)
	write_coe_body(fpout, fpcmd)
end

fpout.close
fpcmd.close

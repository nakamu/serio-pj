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
		bin = 0x2000 | ch << 8 | array[2].to_i
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
		bin = 0x4000 | ch << 8 | array[2].to_i << 4 | array[3].to_i
	when 'halt'
		bin = 0xf000
	else
		# do nothing
	end
	return sprintf("%04x", bin)
end

cmd = ARGV[0]
raise "No input" if(cmd.nil?)

unless(File.exists?(cmd)) then
	raise "Command file #{cmd} does not exist\n"
end

if(File.basename(cmd) =~ /(\w+)\.cmd$/) then
	coe = "#{$1}.coe"
end

fpcmd = File.open(cmd, "r")
fpcoe = File.open(coe, "w")

fpcoe.write("; Sound Sequence from #{cmd}\n")
fpcoe.write("memory_initialization_radix=16;\n")
fpcoe.write("memory_initialization_vector=\n")
first_line = 1
while line = fpcmd.gets
	next if(line =~ /^\s*#/)
	next if(line =~ /^\s*$/)
	if(first_line == 0) then
		fpcoe.write(",\n")
	else
		first_line = 0
	end
	decstr = decode_cmd!(line)
	fpcoe.write(decstr)
end
fpcoe.write(";\n")

fpcoe.close
fpcmd.close

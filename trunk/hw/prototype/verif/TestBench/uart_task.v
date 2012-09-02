
/***** RS232C tasks *****/
reg       receiving;
initial receiving = 1'b0;
reg [7:0] receive;
always @ (posedge rs_clk) begin
	if(~receiving & ~xopTXD) begin
		receive_byte();
	end
end

task receive_byte;
	begin
		receiving = 1'b1;
		@(posedge rs_clk) receive[0] = xopTXD;
		@(posedge rs_clk) receive[1] = xopTXD;
		@(posedge rs_clk) receive[2] = xopTXD;
		@(posedge rs_clk) receive[3] = xopTXD;
		@(posedge rs_clk) receive[4] = xopTXD;
		@(posedge rs_clk) receive[5] = xopTXD;
		@(posedge rs_clk) receive[6] = xopTXD;
		@(posedge rs_clk) receive[7] = xopTXD;
		receiving = 1'b0;
		if(uart_message_on)
			$display("[uart] --> received : 0x%x", receive);
	end
endtask

task send_byte(input [7:0] byte);
	begin
	@(posedge rs_clk) test_top.xipRXD = 1'b1;
	@(posedge rs_clk) test_top.xipRXD = 1'b0;
	@(posedge rs_clk) test_top.xipRXD = byte[0];
	@(posedge rs_clk) test_top.xipRXD = byte[1];
	@(posedge rs_clk) test_top.xipRXD = byte[2];
	@(posedge rs_clk) test_top.xipRXD = byte[3];
	@(posedge rs_clk) test_top.xipRXD = byte[4];
	@(posedge rs_clk) test_top.xipRXD = byte[5];
	@(posedge rs_clk) test_top.xipRXD = byte[6];
	@(posedge rs_clk) test_top.xipRXD = byte[7];
	@(posedge rs_clk) test_top.xipRXD = 1'b1;
	if(uart_message_on)
		$display("[uart] send byte : 0x%x -->", byte);
	end
endtask

task write(input [7:0] addr, input [7:0] data);
	begin
		if(uart_message_on)
			$display("[trans] write 0x%x to 0x%x", data, addr);
		send_byte(8'h01);
		send_byte(addr);
		send_byte(data);
	end
endtask

task burst_write_incr(input [7:0] addr, input [7:0] burst, input [7:0] data);
	integer i;
	begin
		if(uart_message_on)
			$display("[trans] burst write (incremental %d beats) 0x%x to 0x%x", burst+8'h1, data, addr);
		send_byte(8'h11);
		send_byte(addr);
		send_byte(burst);
		for(i = 0; i < burst+8'h1; i = i+1) begin
			send_byte(data);
			data = data + i;
		end
	end
endtask

task burst_write_strm(input [7:0] addr, input [7:0] burst, input [7:0] data);
	integer i;
	begin
		if(uart_message_on)
			$display("[trans] burst write (stream %d beats) 0x%x to 0x%x", burst+8'h1, data, addr);
		send_byte(8'h31);
		send_byte(addr);
		send_byte(burst);
		for(i = 0; i < burst+8'h1; i = i+1) begin
			send_byte(data);
			data = data + i;
		end
	end
endtask

task read(input [7:0] addr, output[7:0] data);
	begin
		if(uart_message_on)
			$display("[trans] read from 0x%x", addr);
		send_byte(8'h02);
		send_byte(addr);
		wait(receiving);
		wait(~receiving);
		data = receive;
	end
endtask

task burst_read_incr(input [7:0] addr, input [7:0] burst);
	integer i;
	begin
		if(uart_message_on)
			$display("[trans] burst read (incremental %d beats) from 0x%x", burst+8'h1, addr);
		send_byte(8'h12);
		send_byte(addr);
		send_byte(burst);
		for(i = 0; i < burst+8'h1; i = i+1) begin
			wait(receiving);
			wait(~receiving);
		end
	end
endtask

task burst_read_strm(input [7:0] addr, input [7:0] burst);
	integer i;
	begin
		if(uart_message_on)
			$display("[trans] burst read (stream %d beats) from 0x%x", burst+8'h1, addr);
		send_byte(8'h32);
		send_byte(addr);
		send_byte(burst);
		for(i = 0; i < burst+8'h1; i = i+1) begin
			wait(receiving);
			wait(~receiving);
		end
	end
endtask


// コマンド定義
#define CMD_UART_SINGLE_WRITE            0x01
#define CMD_UART_INCR_BURST_WRITE   0x03
#define CMD_UART_STRM_BURST_WRITE  0x07
#define CMD_UART_SINGLE_READ              0x10
#define CMD_UART_INCR_BURST_READ     0x30
#define CMD_UART_STRM_BURST_READ     0x70

// mbedのUARTにデータが来るまでwait
void wait_uartRx() {
	while(1) { if(uart.readable()) { break; }
	return;
}

// mbedのUART Txバッファに空きが出るまでwait
void wait_uartTx() {
	while(1) { if(uart.writable()) { break; }
	return;
}

/* SRMD write */
void write_to_fpga_incr_burst(
	unsigned short address,
	unsigned char *data,
	unsigned char burst,
	unsigned char burst_type
) {
	unsigned char addressH, addressL;
	addressH = (address & 0xff00) >> 8;
	addressL = address & 0x00ff;
	
	if(burst_type != CMD_UART_INCR_BURST_WRITE && burst_type != CMD_UART_STRM_BURST_WRITE)  {
		// unsupported burst command
		return;
	}
	
	wait_uartTx(); uart.putc(burst_type); // set command
	wait_uartTx(); uart.putc(addressH);
	wait_uartTx(); uart.putc(addressL); // set target address
	wait_uartTx(); uart.putc(burst); // set burst count
	unsigned char i;
	for(i = 0; i < burst; i++) {
		wait_uartTx(); uart.putc(*data++);
	}
	return;
}

/* Single write */
void write_to_fpga(
	unsigned short address,
	unsigned char data
) {
	unsigned char addressH, addressL;
	addressH = (address & 0xff00) >> 8;
	addressL = address & 0x00ff;
	
	wait_uartTx(); uart.putc(CMD_UART_SINGLE_WRITE); // write command
	wait_uartTx(); uart.putc(addressH);
	wait_uartTx(); uart.putc(addressL); // set target address
	wait_uartTx(); uart.putc(data);
	return;
}

/* SRMD read */
void bread_from_fpga(
	unsigned short address,
	unsigned char *data,
	unsigned char burst,
	unsigned char burst_type
) {
	unsigned char addressH, addressL;
	addressH = (address & 0xff00) >> 8;
	addressL = address & 0x00ff;
	
	if(burst_type != CMD_UART_INCR_BURST_READ && burst_type != CMD_UART_STRM_BURST_READ)  {
		// unsupported burst command
		return;
	}
	wait_uartTx(); uart.putc(burst_type); // set command
	wait_uartTx(); uart.putc(addressH);
	wait_uartTx(); uart.putc(addressL); // set target address
	wait_uartTx(); uart.putc(burst); // set burst count
	unsigned char i;
	for(i = 0; i < burst; i++) {
		wait_uartRx();
		*data = uart.getc(); data++;
	}
	return;
}

/* Single read */
unsigned char read_from_fpga(
	unsigned short address
) {
	unsigned char addressH, addressL;
	addressH = (address & 0xff00) >> 8;
	addressL = address & 0x00ff;
	
	wait_uartTx(); uart.putc(CMD_UART_SINGLE_READ); // write command
	wait_uartTx(); uart.putc(addressH);
	wait_uartTx(); uart.putc(addressL); // set target address
	wait_uartRx(); return uart.getc();
}


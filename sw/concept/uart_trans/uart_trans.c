
// コマンド定義
#define CMD_UART_SINGLE_WRITE       0x01
#define CMD_UART_INCR_BURST_WRITE   0x31
#define CMD_UART_STRM_BURST_WRITE   0x11
#define CMD_UART_SINGLE_READ        0x02
#define CMD_UART_INCR_BURST_READ    0x32
#define CMD_UART_STRM_BURST_READ    0x12

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
void burst_write_to_fpga(
	unsigned char command, 
	unsigned char address,
	unsigned char burst,
	unsigned char *data
) {
	if(burst_type != CMD_UART_INCR_BURST_WRITE && burst_type != CMD_UART_STRM_BURST_WRITE)  {
		// unsupported burst command
		return;
	}

	if(burst == 0) {
		// 0 burst is not allowed
		return;
	}
	
	wait_uartTx(); uart.putc(command); // set command
	wait_uartTx(); uart.putc(address); // set target address
	wait_uartTx(); uart.putc(burst-1); // set burst count
	unsigned char i;
	for(i = 0; i < burst; i++) {
		wait_uartTx(); uart.putc(*data++);
	}
	return;
}

/* Single write */
void write_to_fpga(
	unsigned char address,
	unsigned char data
) {
	
	wait_uartTx(); uart.putc(CMD_UART_SINGLE_WRITE); // write command
	wait_uartTx(); uart.putc(address);               // set target address
	wait_uartTx(); uart.putc(data);
	return;
}

/* SRMD read */
void burst_read_from_fpga(
	unsigned char command, 
	unsigned char address,
	unsigned char burst,
	unsigned char *data
) {

	if(burst_type != CMD_UART_INCR_BURST_READ && burst_type != CMD_UART_STRM_BURST_READ)  {
		// unsupported burst command
		return;
	}

	if(burst == 0) {
		// 0 burst is not allowed
		return;
	}
	
	wait_uartTx(); uart.putc(command); // set command
	wait_uartTx(); uart.putc(address); // set target address
	wait_uartTx(); uart.putc(burst-1); // set burst count
	unsigned char i;
	for(i = 0; i < burst; i++) {
		wait_uartRx();
		*data = uart.getc(); data++;
	}
	return;
}

/* Single read */
unsigned char read_from_fpga(
	unsigned char address
) {
	wait_uartTx(); uart.putc(CMD_UART_SINGLE_READ); // read command
	wait_uartTx(); uart.putc(address);              // set target address
	wait_uartRx(); return uart.getc();
}


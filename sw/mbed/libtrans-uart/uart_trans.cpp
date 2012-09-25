
#include "uart_trans.hpp"

uart_trans::uart_trans() {}

	void write(unsigned char addr, unsigned char *data);
	void burst_write(unsigned char addr, unsigned char *data, 
					 int type, unsigned char burst);
	void read(unsigned char addr, unsigned char *data);
	void burst_read(unsigned char addr, unsigned char *data,
					int type, unsigned char burst); 
	void wait_uartTx();
	void wait_uartRx();


// mbedのUARTにデータが来るまでwait
void uart_trans::wait_uartRx() {
	while(1) { if(uart.readable()) { break; }
	return;
}

// mbedのUART Txバッファに空きが出るまでwait
void uart_trans::wait_uartTx() {
	while(1) { if(uart.writable()) { break; }
	return;
}

void uart_trans::write(unsigned char addr, unsigned char *data) {
	wait_uartTx(); uart.putc(CMD_UART_SINGLE_WRITE); // write command
	wait_uartTx(); uart.putc(address);               // set target address
	wait_uartTx(); uart.putc(*data);
	return;
}

void uart_trans::read(unsigned char addr, unsigned char *data) {
	wait_uartTx(); uart.putc(CMD_UART_SINGLE_READ); // read command
	wait_uartTx(); uart.putc(address);              // set target address
	wait_uartRx(); *data = uart.getc();
	return;
}

void uart_trans::burst_write(
	unsigned char address,
	unsigned char *data,
	int           type,
	unsigned char burst) {

	unsigned char command;
	
	if(type == CMD_BURST_INCR) {
		command = CMD_UART_INCR_BURST_WRITE;
	} else if(type == CMD_BURST_STRM) {
		command = CMD_UART_STRM_BURST_WRITE;
	} else {
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

void uart_trans::burst_read(
	unsigned char address,
	unsigned char *data,
	int           type,
	unsigned char burst) {

	unsigned char command;

	if(type == CMD_BURST_INCR) {
		command = CMD_UART_INCR_BURST_WRITE;
	} else if(type == CMD_BURST_STRM) {
		command = CMD_UART_STRM_BURST_WRITE;
	} else {
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


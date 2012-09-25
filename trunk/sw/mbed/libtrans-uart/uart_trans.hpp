#ifndef _TRANS_UART_HPP
#define _TRANS_UART_HPP

#include "mbed.h"

// Command Definitions
#define CMD_BURST_STRM 0
#define CMD_BURST_INCR 1
#define CMD_UART_SINGLE_WRITE       0x01
#define CMD_UART_INCR_BURST_WRITE   0x31
#define CMD_UART_STRM_BURST_WRITE   0x11
#define CMD_UART_SINGLE_READ        0x02
#define CMD_UART_INCR_BURST_READ    0x32
#define CMD_UART_STRM_BURST_READ    0x12

extern Serial uart;

class uart_trans {
public:
	uart_trans ();
	virtual ~uart_trans() {}
	void write(unsigned char addr, unsigned char *data);
	void burst_write(unsigned char addr, unsigned char *data, 
					 int type, unsigned char burst);
	void read(unsigned char addr, unsigned char *data);
	void burst_read(unsigned char addr, unsigned char *data,
					int type, unsigned char burst); 
private:
	void wait_uartTx();
	void wait_uartRx();
};

#endif

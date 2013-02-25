#ifndef _SCCB_LIB_H_
#define _SCCB_LIB_H_

#include "hold_queue.hpp"
#include "mbed.h"

// 100 us -> 10kHz
#define SCCB_HCYCLE wait_us(50)

// wait between command
#define SCCB_WAIT   wait_ms(10)

#define SCCB_DEBUG

class sccb_lib {
public :
    sccb_lib();
    virtual ~sccb_lib(){};
    void set_device(unsigned char wid, unsigned char rid);
    void write(unsigned char addr, unsigned char data);
    unsigned char read(unsigned char addr);
	void dump_log(Serial console);
private :
    void start();
    void stop();
    void write_byte(unsigned char data);
    unsigned char read_byte();
    unsigned char read_dev;
    unsigned char write_dev;
	void set_scl(int scl);
	void set_sda(int sda);
	int get_sda();
	void sda_drive(int on);
	void sccb_step();
	void sccb_wait();
#ifdef SCCB_DEBUG
	hold_queue scl_log;
	hold_queue sda_log;
#endif
};

#endif

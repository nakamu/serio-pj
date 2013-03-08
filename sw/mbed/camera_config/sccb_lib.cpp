#include "mbed.h"
#include "sccb_lib.hpp"
extern DigitalOut   scl;
extern DigitalInOut sda;

// constructor
sccb_lib::sccb_lib() { 
#ifdef SCCB_DEBUG
	scl_log   = hold_queue();
	sda_log   = hold_queue();
#endif
	set_scl(1);
	sda_drive(1);
	set_sda(1);
}

void sccb_lib::set_device(unsigned char wid, unsigned char rid) {
    write_dev = wid;
    read_dev  = rid;
    return;
}

// Start sequence
void sccb_lib::start() {
	sda_drive(1);
	set_scl(1);
	sccb_step();
	set_sda(1);
	sccb_step();
	sccb_step();
	set_sda(0);
	sccb_step();
    return;
}

// Stop sequence
void sccb_lib::stop() {
	set_scl(0);
	sccb_step();
	sda_drive(1);
	set_sda(0);
	sccb_step();
	set_scl(1);
	sccb_step();
	sccb_step();
	set_sda(1);
	sccb_step();
    return;
}

// primitive write
void sccb_lib::write_byte(unsigned char data) {
    int i;
	sda_drive(1);
    for(i = 7; i >= 0; i--) {
		set_scl(0);
		sccb_step();
        set_sda((data>>i)&0x1);
		sccb_step();
		set_scl(1);
		sccb_step();
    }
	set_scl(0);
	sccb_step();
	sda_drive(0);
	sccb_step();
	set_scl(1);
	sccb_step();
    return;
}

// primitive read
unsigned char sccb_lib::read_byte() {
    unsigned char rd = 0x0;
    int i;
	sda_drive(0);
    for(i = 0; i < 8; i++) {
		set_scl(0);
		sccb_step();
        rd <<= 1;
        rd |= get_sda() & 0x1;
		sccb_step();
		set_scl(1);
		sccb_step();
    }
	set_scl(0);
	sccb_step();
	sda_drive(1);
    set_sda(1);
	sccb_step();
	set_scl(1);
	sccb_step();
    return rd;
}

// write command
void sccb_lib::write(unsigned char addr, unsigned char data) {
    this->start();
    this->write_byte(write_dev);
    this->write_byte(addr);
    this->write_byte(data);
    this->stop();
	sccb_wait();
	return;
}

// read comand
unsigned char sccb_lib::read(unsigned char addr) {
    unsigned char rd;
    this->start();
    this->write_byte(write_dev);
    this->write_byte(addr);
    this->stop();
	sccb_wait();
    this->start();
    this->write_byte(read_dev);
    rd = this->read_byte();
    this->stop();
	sccb_wait();
    return rd;
}

//------------------
// wrapper function
//------------------
void sccb_lib::set_scl(int iscl) {
#ifdef SCCB_DEBUG
	if(iscl == 0) {
		scl_log.set('0');
	} else {
		scl_log.set('1');
	}
#endif
	scl.write(iscl);
	return;
}

void sccb_lib::set_sda(int isda) {
#ifdef SCCB_DEBUG
	if(isda == 0) {
		sda_log.set('0');
	} else {
		sda_log.set('1');
	}
#endif
	sda.write(isda);
	return;
}

int sccb_lib::get_sda() {
	int rd = sda.read();
#ifdef SCCB_DEBUG
	if(rd == 0) {
		sda_log.set('L');
	} else {
		sda_log.set('H');
	}
#endif
	return rd;
}

void sccb_lib::sda_drive (int on) {
	if(on == 0) {
		sda.input();
#ifdef SCCB_DEBUG
		sda_log.set('z');
#endif
	} else {
		sda.output();
#ifdef SCCB_DEBUG
		sda_log.set('X');
#endif
	}
	return;
}

void sccb_lib::sccb_step() {
	SCCB_HCYCLE;
#ifdef SCCB_DEBUG
	scl_log.commit();
	sda_log.commit();
#endif
	return;
}

void sccb_lib::sccb_wait() {
	SCCB_WAIT;
#ifdef SCCB_DEBUG
	scl_log.set('-');
	sda_log.set('-');
	scl_log.commit();
	sda_log.commit();
#endif
	return;
}

void sccb_lib::dump_log(Serial console) {
#ifdef SCCB_DEBUG
	char c;
	console.printf("# Start sccb_lib tracking log.\r\n");
	console.printf("scl: ");
	while(1) {
		c = scl_log.get();
		if(c == 0x0) { break; }
		console.printf("%s", &c);
	}
	console.printf("\r\n");
	console.printf("sda: ");
	while(1) {
		c = sda_log.get();
		if(c == 0x0) { break; }
		console.printf("%s", &c);
	}
	console.printf("\r\n");
	console.printf("# End sccb_lib tracking log.\r\n");
#endif
	return;
}


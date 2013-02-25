#ifndef _OV7670_H_
#define _OV7670_H_

#define OV7670_WRITE_DEV 0x42
#define OV7670_READ_DEV  0x43
//#include "mbed.h"
#include "sccb_lib.hpp"

class ov7670 {
public :
    ov7670();
    virtual ~ov7670() {};
    void configure();
private :
    void set_and_verify(char addr, char data); 
    sccb_lib sccb;
};

#endif

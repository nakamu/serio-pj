#include "mbed.h"

Serial pc(USBTX, USBRX);
DigitalOut leds[] = {(LED1), (LED2), (LED3), (LED4)};

DigitalOut   scl(p29);
DigitalInOut sda(p28);

#include "ov7670.hpp"

int main()
{
    ov7670 camera = ov7670();
    
    for(int i=0; i<4; ++i){
            leds[i] = 0x1;
    }
    wait(0.5);

    pc.baud(115200);
    pc.printf("[Start] mbed now starts writing configuration to OV7670 via sccb\r\n");
    wait(0.5);
    
    camera.configure();
    
    for(int i=0; i<4; ++i){
            leds[i] = 0x0;
    }
    pc.printf("[End] mbed finished configuration!!\r\n");
    return 0;
}

#include "mbed.h"
#include "TextLCD.h"

DigitalOut      MouseClkPin(p27);
DigitalInOut    MouseDataPin(p28);
TextLCD lcd(p25, p24, p12, p13, p14, p23); // for maple board

// MouseData.input();
// return MouseData;
// MouseData.output();
// MouseData = Bit;

int MouseAddress[7] ={0,0,0,0,0,0,0};
int MouseData[8]    ={0,0,0,0,0,0,0,0};
int x;
int y;

int Bit;

int readBit(){
    wait_us(0.1);
    MouseClkPin=0;
    wait_us(0.2);
    MouseClkPin=1;
    Bit=MouseDataPin;
    wait_us(0.2);
    return MouseDataPin;
}

int writeBit(int writeData){
    MouseDataPin=writeData;
    wait_us(0.1);
    MouseClkPin=0;
    wait_us(0.2);
    MouseClkPin=1;
    wait_us(0.2);
    return 0;
}

int readData() {
    MouseDataPin.output();
    writeBit(0);
    for(int i=0; i<7; i++){
        writeBit(MouseAddress[6-i]);
    }
    MouseDataPin.input();
    for(int i=0; i<8; i++){
        MouseData[7-i]=readBit();
    }
    return 0;
}

int writeData(){
    MouseDataPin.output();
    writeBit(1);
    for(int i=0; i<7; i++){
        writeBit(MouseAddress[6-i]);
    }
    for(int i=0; i<8; i++){
        writeBit(MouseData[7-i]);
    }
    return 0;
}

int main() {
    // lcd.printf("MouseTest\n");
    // initialization
    wait_ms(100);
    MouseAddress[6]=0;
    MouseAddress[5]=0;
    MouseAddress[4]=1;
    MouseAddress[3]=1;
    MouseAddress[2]=0;
    MouseAddress[1]=1;
    MouseAddress[0]=1; // 0x1B Configuration bits:
    MouseData[7]=0; // 7: Set to 1 for 500 dpi; 0 (default) for 1000 dpi. 
    writeData();
    while(1) {
        MouseAddress[6]=0;
        MouseAddress[5]=0;
        MouseAddress[4]=1;
        MouseAddress[3]=0;
        MouseAddress[2]=1;
        MouseAddress[1]=1;
        MouseAddress[0]=0; 
        readData();
        //lcd.printf("MotionDet:%x\n\n",MouseData[7]);
        if(MouseData[7]==1);
            MouseAddress[6]=0;
            MouseAddress[5]=0;
            MouseAddress[4]=0;
            MouseAddress[3]=0;
            MouseAddress[2]=0;
            MouseAddress[1]=1;
            MouseAddress[0]=0; 
            readData();
            lcd.printf("x:");
            lcd.printf("%x",MouseData[7]);
            lcd.printf("%x",MouseData[6]);
            lcd.printf("%x",MouseData[5]);
            lcd.printf("%x",MouseData[4]);
            lcd.printf("%x",MouseData[3]);
            lcd.printf("%x",MouseData[2]);
            lcd.printf("%x",MouseData[1]);
            lcd.printf("%x",MouseData[0]);
            lcd.printf("\n");
            MouseAddress[6]=0;
            MouseAddress[5]=0;
            MouseAddress[4]=0;
            MouseAddress[3]=0;
            MouseAddress[2]=0;
            MouseAddress[1]=1;
            MouseAddress[0]=1; 
            readData();
            lcd.printf("y:");
            lcd.printf("%x",MouseData[7]);
            lcd.printf("%x",MouseData[6]);
            lcd.printf("%x",MouseData[5]);
            lcd.printf("%x",MouseData[4]);
            lcd.printf("%x",MouseData[3]);
            lcd.printf("%x",MouseData[2]);
            lcd.printf("%x",MouseData[1]);
            lcd.printf("%x",MouseData[0]);
            lcd.printf("\n");
        wait_ms(100);
    }
}

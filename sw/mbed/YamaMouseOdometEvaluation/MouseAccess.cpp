#include "mbed.h"

extern  DigitalOut      MouseClkPin;
extern  DigitalInOut    MouseDataPin;

int readBit();
int readByte();
void writeBit(int write1bitData);
void write7Bit(int write7Bit);
int readData(int MouseAddress);
void writeData(int MouseAddress, int MouseData);



int readBit(){
  int Bit;

  wait_us(0.1);
  MouseClkPin=0;
  wait_us(0.2);
  MouseClkPin=1;
  Bit=MouseDataPin; //Dummy (For Access Timing)
  wait_us(0.2);
  Bit=MouseDataPin;
  return Bit;
}

int readByte(){
  int ii;
  int data=0;

  for(ii=0; ii<8; ii++){
    data|=((readBit()&1)<<(7-ii));
  }
  return data;
}


void writeBit(int write1bitData){
  MouseDataPin=write1bitData;
  wait_us(0.1);
  MouseClkPin=0;
  wait_us(0.2);
  MouseClkPin=1;
  wait_us(0.2);
}


void write7Bit(int write7Bit){
  int ii;
  int chunk1bitdata;

  for(ii=0; ii<7; ii++){
    chunk1bitdata=(write7Bit>>(6-ii)) & 1; //Trimming 1Bit
    writeBit(chunk1bitdata);
  }
}



int readData(int MouseAddress) {
  short int MouseData;
  MouseDataPin.output();
  writeBit(0); //READ_MODE
  write7Bit(MouseAddress);

  MouseDataPin.input();
  MouseData=readByte();

  MouseData=MouseData<<8;
  MouseData=MouseData>>8;

  return (int)MouseData;
}

void writeData(int MouseAddress, int MouseData){
  MouseDataPin.output();
  writeBit(1); //WRITE_MODE
  write7Bit(MouseAddress);

  int ii;
  int chunk1bitdata;
  for(ii=0; ii<7; ii++){
    chunk1bitdata=(MouseData>>(7-ii)) & 1;
    writeBit(chunk1bitdata);
  }
}

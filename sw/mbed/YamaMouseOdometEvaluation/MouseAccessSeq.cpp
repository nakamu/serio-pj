#include "mbed.h"

#include<queue>
#include<complex>

using namespace std;

extern void write7Bit();
extern int readData(int MouseAddress);
extern void writeData(int MouseAddress, int MouseData);



void MouseAccessSetup(){
  int addr;

  addr=0x1B; //Configuration Bits
  writeData(addr, 0x00);//At-7Bit [7]: Set to 1 for 500 dpi; 0 (default) for 1000 dpi. 
}




//Real=Xcoord, Imag=Ycoord
//The following code is run on 1000dpi.  

complex<int> MouseAccessSeq(int Sampling){
  static queue<int> totxcoord;
  static queue<int> totycoord;
  int addr;
  int xcoord=0;
  int ycoord=0;
  int ii;

  if(Sampling==0){
    return complex<int>(0,0); //Error
  }

  //----
  xcoord=0;
  ycoord=0;

  for(ii=0; ii<Sampling; ii++){
    addr=0x02; //X-coordinate
    xcoord+=readData(addr);
    addr=0x03;
    ycoord+=readData(addr);
    wait_ms(100);
  }
  xcoord=xcoord/Sampling;
  ycoord=ycoord/Sampling;

  return complex<int>(xcoord, ycoord);
}

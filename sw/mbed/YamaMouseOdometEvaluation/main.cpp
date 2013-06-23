#include "mbed.h"
#include "TextLCD.h"

#include <queue>
#include <complex>

DigitalOut      MouseClkPin(p15);
DigitalInOut    MouseDataPin(p16);
TextLCD lcd(p24, p26, p27, p28, p29, p30); // for maple board

extern void MouseAccessSetup();
extern complex<int> MouseAccessSeq(int Sampling);


using namespace std;

int main(){
  int ii;
  //int jj;

  int xcoord;
  int ycoord;
  int totalx=0;
  int totaly=0;

  complex<int> coord;

  wait_ms(100);
  MouseAccessSetup(); //1000dpi Mouse Setup

  coord=MouseAccessSeq(1); //Dummyで1回打ち込む



  ii=0;
  while(true){
    coord=MouseAccessSeq(1);
    xcoord=coord.real();
    ycoord=coord.imag();



//     if(ii>1000){ //1000毎に初期化
//       ii=0;
//       totalx=xcoord;
//       totaly=ycoord;
//       ii++;
//     }
//     else{
    totalx+=xcoord;
    totaly+=ycoord;
//     }


    lcd.printf("x %04x,y %04x", xcoord&0xffff, ycoord&0xffff);
    //lcd.printf("%d", ii);
    lcd.printf("\n");
    lcd.printf("%06x, %06x", totalx&0xffffff, totaly&0xffffff);
    lcd.printf("\n");
//     lcd.printf("x:");
//     lcd.printf("%08x",totalx);
//     lcd.printf("\n");
//     lcd.printf("y:");
//     lcd.printf("%08x",totaly);
//     lcd.printf("\n");
  }
}

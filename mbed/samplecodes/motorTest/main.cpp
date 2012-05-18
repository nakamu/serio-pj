#include "mbed.h"
#include "myUsePin.hpp"
#include "myMotorTest.hpp"

//Switch Trigger
DigitalIn  myInTrigBtn(p20); //Trigger
DigitalIn  myInResetBtn(p5);  //Reset
//Motor Output
DigitalOut myOutMotor1(p21);
DigitalOut myOutMotor2(p22);
//LED Output
DigitalOut myOutLed1(LED1);
DigitalOut myOutLed2(LED2);



int main() {
  MyMotor mymotor;
  mymotor.run();
}

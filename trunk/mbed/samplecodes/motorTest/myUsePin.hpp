#ifndef _MYUSEPIN_HPP
#define _MYUSEPIN_HPP
#include "mbed.h"

//Switch Trigger
extern DigitalIn  myInTrigBtn;//(p20); //Trigger
extern DigitalIn  myInResetBtn;//(p5);  //Reset
//Motor Output
extern DigitalOut myOutMotor1;//(p21);
extern DigitalOut myOutMotor2;//(p22);
//LED Output
extern DigitalOut myOutLed1;//(LED1);
extern DigitalOut myOutLed2;//(LED2);


#endif
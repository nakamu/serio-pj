#include "myMotorTest.hpp"
#include "myUsePin.hpp"

MyMotor::MyMotor(){
  myInTrigBtn.mode(PullUp);
//  myInResetBtn.mode(PullUp);
  myState=eStaOff;
}


void  MyMotor:: run(){
  while(true){
    myState=NextState(myState, myInTrigBtn.read());
    Output(myState);
    wait(WAITTIME);
  }
}


void MyMotor::Output(eState curstate){

  switch(curstate){
  case eStaOff:
    myOutMotor1=0;
    myOutMotor2=0;
    myOutLed1=0;
    myOutLed2=0;
    break;
  case eStaActL:
    myOutMotor1=1;
    myOutMotor2=0;
    myOutLed1=1;
    myOutLed2=0;
    break;
  case eStaActR:
    myOutMotor1=0;
    myOutMotor2=1;
    myOutLed1=0;
    myOutLed2=1;
    break;
  case eStaActLR:
    myOutMotor1=1;
    myOutMotor2=1;
    myOutLed1=1;
    myOutLed2=1;
    break;
  default:
    myOutMotor1=0;
    myOutMotor2=0;
    myOutLed1=0;
    myOutLed2=0;
    break;
  }
}



eState MyMotor::NextState(eState curstate, bool trigger){
//  if(reset) return eStaOff;
  switch(curstate){
  case eStaOff:
    if(trigger==0) return eStaActL;
    else           return eStaOff;
  case eStaActL:
    if(trigger==0) return eStaActR;
    else           return eStaActL;
  case eStaActR:
    if(trigger==0) return eStaActLR;
    else           return eStaActR;
  case eStaActLR:
    if(trigger==0) return eStaOff;
    else           return eStaActLR;
  default:
    return eStaOff;
  }
}

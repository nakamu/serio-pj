#ifndef _MYMOTORTEST_HPP
#define _MYMOTORTEST_HPP
#include "mbed.h"

#include "myUsePin.hpp"


enum eState{eStaOff, eStaActL, eStaActR, eStaActLR};
#define WAITTIME 0.25




class MyMotor{
public:
  MyMotor();
  virtual ~MyMotor(){}
  void run();
protected:
  void Output(eState curstate);
  eState NextState(eState curstate, bool trigger, bool reset);


protected:
  eState myState;
};

#endif

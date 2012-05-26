#include "mbed.h"
#include "pwmParameter.hpp"
#include "Prompt.hpp"

/****************************************
 *            IO declarations           *
 ****************************************/
// UART connection
//Serial     pc(p9, p10);
Serial     pc(USBTX, USBRX);
//Switch (Low active)
//DigitalIn  button(p20);
InterruptIn button(p18);
//Motor Output
PwmOut     pwm1(p21);
PwmOut     pwm2(p22);

//LED Output ( debug out )
DigitalOut Led1(LED1);
DigitalOut Led2(LED2);
DigitalOut Led3(LED3);
//DigitalOut Led4(LED4);
DigitalOut FixLow(p23);
DigitalOut FixHigh(p24);

Ticker timer;

/* global variables */
enum eState {ON, OFF};
eState state;
pwmParameter ch1;
pwmParameter ch2;

/* Switch Interrupt */
void switchOnOff() {
    if     (state == ON)  { state = OFF; Led1 = 0; }
    else if(state == OFF) { state = ON;  Led1 = 1; }
    else                  { state = OFF; Led1 = 0; }
}

/* Timer Interupt */
void updatePWM() {
    Led2 = !Led2;
    if(state == OFF) {
        pwm1.write(0.0f); // stop pwm
        pwm2.write(0.0f); // stop pwm
    } else {
        // set duty cycle
        pwm1.write(ch1.get_duty());
        pwm2.write(ch2.get_duty());
        // set period
        pwm1.period_ms(ch1.get_period());
        pwm2.period_ms(ch2.get_period());
        // set pulse width
        pwm1.pulsewidth_ms(ch1.get_pulsewidth());
        pwm2.pulsewidth_ms(ch2.get_pulsewidth());
    }
}

/* main routine */
int main() {
  Prompt prompt;
  // add interrupt vector on fall edge of p20
  button.fall(&switchOnOff);
  
  // update pwm setting at every 1s

  timer.attach(&updatePWM, 1.0f);
  Led3 = 1;
  FixHigh = 1;
  FixLow = 0;
  
  // serial baudrate is 9600 bps
  //pc.baud(9600);
  //pc.format(8, Serial::None, 1);

  // launch prompt
  prompt.run();
}


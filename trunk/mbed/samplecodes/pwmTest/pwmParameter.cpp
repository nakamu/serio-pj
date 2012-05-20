#include "pwmParameter.hpp"

// constructor
pwmParameter::pwmParameter(){
    duty       = 0.5f;
    period     = 100.0f;
    pulsewidth = 10.0f;
}

void pwmParameter::set_duty(float in) {
    if(in > 1.00) { duty = 1.0f; }
    else          { duty = in; }
}

void pwmParameter::set_period(float in) {
    period = in;
}

void pwmParameter::set_pulsewidth(float in) {
    pulsewidth = in;
}

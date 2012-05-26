#ifndef _PROMPT_HPP
#define _PROMPT_HPP
#include "mbed.h"
#include "pwmParameter.hpp"
#include <string>

extern Serial pc;
extern pwmParameter ch1;
extern pwmParameter ch2;

class Prompt {
public:
    Prompt();
    virtual ~Prompt() {}
    void run();
protected:
    void   hello();
    int    ask_ch();
    float  ask_duty();
    float  ask_period();
    float  ask_pulsewidth();
    float  get_float();
    string get_line();
};

#endif

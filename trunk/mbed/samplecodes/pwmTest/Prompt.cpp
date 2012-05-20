#include "Prompt.hpp"
#include <string>

Prompt::Prompt() {
    hello();
}

void Prompt::hello() {
    pc.printf("*** Hello, this is serio prototype. ***\n");
}

void Prompt::run() {
    while(true) {
        while(true) {
            pc.printf("Press Enter to configure PWM setting");
            if(pc.getc() == '\n') { break; }
        }
        // get configuration from prompt
        int   ch     = ask_ch();
        float duty   = ask_duty();
        float period = ask_period();
        float pulsew = ask_pulsewidth();
        // set configuration
        if((ch == 0) || (ch == 1)) {
            ch1.set_duty(duty);
            ch1.set_period(period);
            ch1.set_pulsewidth(pulsew);
        }
        if((ch == 0) || (ch == 2)) {
            ch2.set_duty(duty);
            ch2.set_period(period);
            ch2.set_pulsewidth(pulsew);
        }
    }
}

int Prompt::ask_ch() {
    int conf = -1;
    while(true) {
        pc.printf("Which channel do you want to configure?\n");
        pc.printf("  Ch.1 : Type '1'\n");
        pc.printf("  Ch.2 : Type '2'\n");
        pc.printf("  Both : Type 'b'\n");
        char c = pc.getc();
        switch(c) {
        case '1': conf = 1; pc.printf("->Ch.1 is selected\n"); break;
        case '2': conf = 2; pc.printf("->Ch.2 is selected\n"); break;
        case 'b': conf = 0; pc.printf("->Ch.1 & 2 are selected\n");  break;
        default : break; 
        }
        if(conf >= 0) { break; }
        pc.printf("Press 1 or 2 or b\n");
    }
    return conf;
}

float Prompt::ask_duty() {
    float f;
    pc.printf("Configure duty : ");
    while(true) {
        f = get_float();
        if((0.0f <= f)&&(f <= 1.0f)) {
            pc.printf("-> OK, duty will be set to %f\n", f);
            break;
        } else {
            pc.printf("invalid duty : %f\n", f);
        }
    }
    return f;
}

float Prompt::ask_period() {
    float f;
    pc.printf("Configure period (in ms): ");
    f = get_float();
    pc.printf("-> OK, period will be set to %fms\n", f);
    return f;
}

float Prompt::ask_pulsewidth() {
    float f;
    pc.printf("Configure pulsewidth (in ms): ");
    f = get_float();
    pc.printf("-> OK, pulse width will be set to %fms\n", f);
    return f;
}

float Prompt::get_float() {
    float f;
    string str;
    char c;
    while(true) {
        while((c = pc.getc()) != '\n') { str += c; }
        f = atof(str.c_str());
        if(0.0f <= f) {
            break;
        }
    }
    return f;
}

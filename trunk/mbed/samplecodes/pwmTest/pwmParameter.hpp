#ifndef _PWMPARAMETER_HPP
#define _PWMPARAMETER_HPP

class pwmParameter {
public:
    pwmParameter();
    virtual ~pwmParameter(){}
    float get_duty()       { return duty; }
    float get_period()     { return period; }
    float get_pulsewidth() { return pulsewidth; }
    void set_duty(float in);
    void set_period(float in);
    void set_pulsewidth(float in);
protected:
    float duty;
    float period;
    float pulsewidth;
};

#endif

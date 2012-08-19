#include "mbed.h"
#include "SDHCFileSystem.h"



//SDFileSystem sd(p5, p6, p7, p8, "sd");
SDFileSystem sd(p5, p6, p7, p8, "sd"); // mosi, miso, sclk, cs, name

int main() {
    unsigned int ii;
    unsigned int jj;

    printf("Hello World!\n");   

    FILE *fp = fopen("/sd/aaaaaaa.txt", "w");
    if(fp == NULL) {
        error("Could not open file for write\n");
    }
    
    Timer wtime;
    wtime.start();
    //1MB-Write
    for(ii=0; ii<1000; ii++){
        fprintf(fp, "1");//1Byte
    }
    wtime.stop();
    
    printf("Write Time is %d ms\n", wtime.read_ms());
    
    fclose(fp); 

    printf("Goodbye World!\n");
}   

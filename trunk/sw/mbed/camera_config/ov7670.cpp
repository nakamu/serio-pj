#include "ov7670.hpp"
#include "mbed.h"
extern Serial pc;

ov7670::ov7670() {
    sccb = sccb_lib();
    sccb.set_device(OV7670_WRITE_DEV, OV7670_READ_DEV);
}

void ov7670::set_and_verify (char addr, char data)
{
    unsigned char ri, rw;
    pc.printf("[set]    setting 0x%x to 0x%x...\r\n", addr, data);
    ri = this->sccb.read(addr);
    this->sccb.write(addr, data);
    pc.printf("[verify] verifing...");
    rw = this->sccb.read(addr);
    if(rw != (int)data) {
        pc.printf(" FAIL\r\n => addr=0x%x, init=0x%x, read=0x%x (exp 0x%x)\r\n", addr, ri, rw, data);
    } else {
        pc.printf(" PASS\r\n");
    }
    return;
}

void ov7670::configure(){    this->set_and_verify(0x00, 0x00);

    // 0x01 BLUE : 0x80 -> 0x40
    this->set_and_verify(0x01, 0x40);

    // 0x02 RED  : 0x80 -> 0x60
    this->set_and_verify(0x02, 0x60);

    // 0x03 VREF : 0x00 -> 0x0a
    this->set_and_verify(0x03, 0x0a);

    // 0x04 COM1 : 0x00 -> 0x00
    this->set_and_verify(0x04, 0x00);

    // 0x05 BAVE : 0x00 -> 0x00
    this->set_and_verify(0x05, 0x00);

    // 0x06 GbAve : 0x00 -> 0x00
    this->set_and_verify(0x06, 0x00);

    // 0x07 AECHH : 0x00 -> 0x00
    this->set_and_verify(0x07, 0x00);

    // 0x08 RAVE : 0x00 -> 0x00
    this->set_and_verify(0x08, 0x00);

    // 0x09 COM2 : 0x01 -> 0x01
    this->set_and_verify(0x09, 0x01);

    // 0x0c COM3 : 0x00 -> 0x00
    this->set_and_verify(0x0c, 0x00);

    // 0x0d COM4 : 0x00 -> 0x00
    this->set_and_verify(0x0d, 0x00);

    // 0x0e COM5 : 0x01 -> 0x61
    this->set_and_verify(0x0e, 0x61);

    // 0x0f COM6 : 0x43 -> 0x4b
    // [1] Reset all timing when format changes
    // [7] Output of optical black line ?
    this->set_and_verify(0x0f, 0x4b);

    // 0x10 AECH : 0x40 -> 0x40
    this->set_and_verify(0x10, 0x40);

    // 0x11 CLKRC : 0x80 -> 0x80
    this->set_and_verify(0x11, 0x80);

    // 0x12 COM7 : 0x00 -> 0x04
    // [0] Output format - Raw RGB
    // [1] Color bar ?
    // [2] Output format - RGB selection
    // [3] Output format - QCIF selection
    // [4] Output format - QVGA selection
    // [5] Output format - CIF selection
    // [7] SCCB register reset (active-H)
    this->set_and_verify(0x12, 0x04);

    // 0x13 COM8 : 0x8F -> 0x8F
    this->set_and_verify(0x13, 0x8F);

    // 0x14 COM9 : 0x4A -> 0x4A
    this->set_and_verify(0x14, 0x4A);

    // 0x15 COM10 : 0x00 -> 0x00
    this->set_and_verify(0x15, 0x00);

    // 0x16 RSVD : 0xXX -> 0x02
    this->set_and_verify(0x16, 0x02);

    // 0x17 HSTART : 0x11 -> 0x13
    this->set_and_verify(0x17, 0x13);

    // 0x18 HSTOP : 0x61 -> 0x01
    this->set_and_verify(0x18, 0x01);

    // 0x19 VSTRT : 0x03 -> 0x02
    this->set_and_verify(0x19, 0x02);

    // 0x1a VSTOP : 0x7B -> 0x7a
    this->set_and_verify(0x1a, 0x7a);

    // 0x1b PSHFT : 0x00 -> 0x00
    this->set_and_verify(0x1b, 0x00);

    // 0x1e MVFP : 0x01 -> 0x07
    // [2] Black sun enable
    // [4] VFlip enable
    // [5] Mirror
    this->set_and_verify(0x1e, 0x07);

    // 0x20 ADCCTR0 : 0x04 -> 0x04
    this->set_and_verify(0x20, 0x04);

    // 0x21 ADCCTR1 : 0x02 -> 0x02
    this->set_and_verify(0x21, 0x02);

    // 0x22 ADCCTR2 : 0x01 -> 0x91
    this->set_and_verify(0x22, 0x91);

    // 0x23 ADCCTR3 : 0x00 -> 0x00
    this->set_and_verify(0x23, 0x00);

    // 0x24 AEW : 0x75 -> 0x75
    this->set_and_verify(0x24, 0x75);

    // 0x25 AEB : 0x63 -> 0x63
    this->set_and_verify(0x25, 0x63);

    // 0x26 VPT : 0xD4 -> 0xD4
    this->set_and_verify(0x26, 0xd4);

    // 0x27 BBIAS : 0x80 -> 0x80
    this->set_and_verify(0x27, 0x80);

    // 0x28 GbBIAS : 0x80 -> 0x80
    this->set_and_verify(0x28, 0x80);

    // 0x29 RSVD : 0xXX -> 0x07
    this->set_and_verify(0x29, 0x07);

    // 0x2a EXHCH : 0x00 -> 0x00
    this->set_and_verify(0x2a, 0x00);

    // 0x2b EXHCL : 0x00 -> 0x00
    this->set_and_verify(0x2b, 0x00);

    // 0x2c RBIAS : 0x80 -> 0x80
    this->set_and_verify(0x2c, 0x80);

    // 0x2d ADVFL : 0x00 -> 0x00
    this->set_and_verify(0x2d, 0x00);

    // 0x2e ADVFH : 0x00 -> 0x00
    this->set_and_verify(0x2e, 0x00);

    // 0x2f YAVE : 0x00 -> 0x00
    this->set_and_verify(0x2f, 0x00);

    // 0x30 HSYST : 0x08 -> 0x08
    this->set_and_verify(0x30, 0x08);

    // 0x31 HSYEN : 0x30 -> 0x30
    this->set_and_verify(0x31, 0x30);

    // 0x32 HREF : 0x80 -> 0xb6
    this->set_and_verify(0x32, 0xb6);

    // 0x33 CHLF : 0x08 -> 0x0b
    this->set_and_verify(0x33, 0x0b);

    // 0x34 ARBLM : 0x11 -> 0x11
    this->set_and_verify(0x34, 0x11);

    // 0x37 ADC : 0x3F -> 0x1d
    this->set_and_verify(0x37, 0x1d);

    // 0x38 ACOM : 0x01 -> 0x71
    this->set_and_verify(0x38, 0x71);

    // 0x39 OFON : 0x00 -> 0x00
    this->set_and_verify(0x39, 0x2a);

    // 0x3a TSLB : 0x0d -> 0x0d
    this->set_and_verify(0x3a, 0x0d);

    // 0x3b COM11 : 0x00 -> 0x12
    // [1] Exposure timing can be less than limit of banding filter when light
    //     is too strong
    // [3] Banding filter value select (effective only when COM11[4]==0)
    // [4] D56_Auto
    // [6:5] Minimum frame rate of night mode
    // [7] Night mode
    this->set_and_verify(0x3b, 0x12);

    // 0x3c COM12 : 0x68 -> 0x78
    // [7] HREF option
    this->set_and_verify(0x3c, 0x78);

    // 0x3d COM13 : 0x88 -> 0x88
    // [0] UV swap
    // [6] UV saturation level
    // [7] Gamma enable
    this->set_and_verify(0x3d, 0xc3);

    // 0x3e COM14 : 0x00 -> 0x00
    // [2:0] PCLK divider
    // [3] manual scaling enable
    // [4] DCW and scaling PCLK enable
    this->set_and_verify(0x3e, 0x00);

    // 0x3f EDGE : 0x00 -> 0x00
    // [4:0] Edge enhancement factor
    this->set_and_verify(0x3f, 0x00);

    // 0x40 COM15 : 0xc0 -> 0xd0 (8(b11010000)
    // [5:4] RGB 555/565 option (must be COM7[2],COM7[0]==2(b10)
    // [7:6] Data format - output full range enable
    this->set_and_verify(0x40, 0xd0);

    // 0x41 COM16 : 0x08 -> 0x08
    // [1] color matrix coefficient double option
    // [3] AWB gain enable
    // [4] de-noise threshold auto-adjustment
    // [5] enable edge enhancement threshold auto-adjustment for YUV output
    this->set_and_verify(0x41, 0x08);

    // 0x41 COM16 : 0x08 -> 0x18
    // [1] color matrix coefficient double option
    // [3] AWB gain enable
    // [4] de-noise threshold auto-adjustment
    // [5] enable edge enhancement threshold auto-adjustment for YUV output
    this->set_and_verify(0x41, 0x38);

    // 0x42 COM17 : 0x00 -> 0x00
    // [3] DSP color bar enable
    // [7:6] AEC window must be the same valud as COM4[5:4]
    this->set_and_verify(0x42, 0x00);

    // 0x43 AWBC1 : 0x14 -> 0x0a
    this->set_and_verify(0x43, 0x0a);

    // 0x44 AWBC2 : 0xf0 -> 0xf0
    this->set_and_verify(0x44, 0xf0);

    // 0x45 AWBC3 : 0x45 -> 0x34
    this->set_and_verify(0x45, 0x34);

    // 0x46 AWBC4 : 0x61 -> 0x58
    this->set_and_verify(0x46, 0x58);

    // 0x47 AWBC5 : 0x51 -> 0x28
    this->set_and_verify(0x47, 0x28);

    // 0x48 AWBC6 : 0x79 -> 0x3a
    this->set_and_verify(0x48, 0x3a);

    // 0x4b REG4B : 0x00 -> 0x09
    // [0] UB average enable
    this->set_and_verify(0x4b, 0x09);

    // 0x4c DNSTH : 0x00 -> 0x00
    this->set_and_verify(0x4c, 0x00);

    // 0x4d RSVD : 0xXX -> 0x40
    this->set_and_verify(0x4d, 0x40);

    // 0x4e RSVD : 0xXX -> 0x20
    this->set_and_verify(0x4e, 0x20);

    // 0x4f MTX1 : 0x40 -> 0x80
    this->set_and_verify(0x4f, 0x80);

    // 0x50 MTX2 : 0x34 -> 0x80
    this->set_and_verify(0x50, 0x80);

    // 0x51 MTX3 : 0x0c -> 0x00
    this->set_and_verify(0x51, 0x00);

    // 0x52 MTX4 : 0x17 -> 0x22
    this->set_and_verify(0x52, 0x22);

    // 0x53 MTX5 : 0x29 -> 0x5e
    this->set_and_verify(0x53, 0x5e);

    // 0x54 MTX6 : 0x40 -> 0x40
    this->set_and_verify(0x54, 0x80);

    // 0x55 BRIGHT : 0x00 -> 0x00
    this->set_and_verify(0x55, 0x00);

    // 0x56 CONTRAS: 0x40 -> 0x40
    this->set_and_verify(0x56, 0x40);

    // 0x57 CONTRASCENTER : 0x80 -> 0x80
    this->set_and_verify(0x57, 0x80);

    // 0x58 MTXS : 0x1e -> 0x9e
    // [5:0] Maxrix coefficient sign
    // [7]   Auto contrast center enable
    this->set_and_verify(0x58, 0x9e);

    // 0x59 RSVD : 0xXX -> 0x88
    this->set_and_verify(0x59, 0x88);

    // 0x5a RSVD : 0xXX -> 0x88
    this->set_and_verify(0x5a, 0x88);

    // 0x5b RSVD : 0xXX -> 0x44
    this->set_and_verify(0x5b, 0x44);

    // 0x5c RSVD : 0xXX -> 0x67
    this->set_and_verify(0x5c, 0x67);

    // 0x5d RSVD : 0xXX -> 0x49
    this->set_and_verify(0x5d, 0x49);

    // 0x5e RSVD : 0xXX -> 0x0e
    this->set_and_verify(0x5e, 0x0e);

    // 0x62 LCC1 : 0x00 -> 0x00
    this->set_and_verify(0x62, 0x00);

    // 0x63 LCC2 : 0x00 -> 0x00
    this->set_and_verify(0x63, 0x00);

    // 0x64 LCC3 : 0x50 -> 0x50
    this->set_and_verify(0x64, 0x50);

    // 0x65 LCC4 : 0x30 -> 0x30
    this->set_and_verify(0x65, 0x30);

    // 0x66 LCC5 : 0x00 -> 0x00
    this->set_and_verify(0x66, 0x00);

    // 0x67 MANU : 0x80 -> 0x80
    this->set_and_verify(0x67, 0x80);

    // 0x68 MANV : 0x80 -> 0x80
    this->set_and_verify(0x68, 0x80);

    // 0x69 GFIX : 0x00 -> 0x00
    this->set_and_verify(0x69, 0x00);

    // 0x6a GGAIN : 0x00 -> 0x40
    this->set_and_verify(0x6a, 0x40);

    // 0x6b DBLV : 0x0a -> 0x0a
    this->set_and_verify(0x6b, 0x0a);

    // 0x6c AWBCTR3 : 0x02 -> 0x0a
    this->set_and_verify(0x6c, 0x0a);

    // 0x6d AWBCTR2 : 0x55 -> 0x55
    this->set_and_verify(0x6d, 0x55);

    // 0x6e AWBCTR1 : 0xC0 -> 0x11
    this->set_and_verify(0x6e, 0x11);

    // 0x6f AWBCTR0 : 0x9a -> 0x9a
    this->set_and_verify(0x6f, 0x9f);

    // 0x70 SCALING_XSC : 0x3a -> 0x3a
    this->set_and_verify(0x70, 0x3a);

    // 0x71 SCALING_YSC : 0x35 -> 0x35
    this->set_and_verify(0x71, 0x35);

    // 0x72 SCALING_DCWCTR : 0x11 -> 0x11
    this->set_and_verify(0x72, 0x11);

    // 0x73 SCALING_PCLK_DIV : 0x00 -> 0xf0
    this->set_and_verify(0x73, 0xf0);

    // 0x74 REG74 : 0x00 -> 0x10
    this->set_and_verify(0x74, 0x10);

    // 0x75 REG75 : 0x0f -> 0x05
    // [4:0] Edge enhancement lower limit
    this->set_and_verify(0x75, 0x05);

    // 0x76 REG76 : 0x01 -> 0xe1
    // [4:0] Edge enhancement higher limit
    // [6] white pixel correction enable
    // [7] black pixel correction enable
    this->set_and_verify(0x76, 0xe1);

    // 0x77 REG77 : 0x10 -> 0x01
    // [7:0] de-noise offset
    this->set_and_verify(0x77, 0x01);

    // 0x7a SLOP : 0x24 -> 0x24
    // [7:0] Gamma curve highest segment slope
    this->set_and_verify(0x7a, 0x24);

    // 0x7b GAM1 : 0x04 -> 0x04
    this->set_and_verify(0x7b, 0x04);

    // 0x7c GAM2 : 0x07 -> 0x07
    this->set_and_verify(0x7c, 0x07);

    // 0x7d GAM3 : 0x10 -> 0x10
    this->set_and_verify(0x7d, 0x10);

    // 0x7e GAM4 : 0x28 -> 0x28
    this->set_and_verify(0x7e, 0x28);

    // 0x7f GAM5 : 0x36 -> 0x36
    this->set_and_verify(0x7f, 0x36);

    // 0x80 GAM6 : 0x44 -> 0x44
    this->set_and_verify(0x80, 0x44);

    // 0x81 GAM7 : 0x52 -> 0x52
    this->set_and_verify(0x81, 0x52);

    // 0x82 GAM8 : 0x60 -> 0x60
    this->set_and_verify(0x82, 0x60);

    // 0x83 GAM9 : 0x6c -> 0x6c
    this->set_and_verify(0x83, 0x6c);

    // 0x84 GAM10 : 0x78 -> 0x78
    this->set_and_verify(0x84, 0x78);

    // 0x85 GAM11 : 0x8c -> 0x8c
    this->set_and_verify(0x85, 0x8c);

    // 0x86 GAM12 : 0x9e -> 0x9e
    this->set_and_verify(0x86, 0x9e);

    // 0x87 GAM13 : 0xbb -> 0xbb
    this->set_and_verify(0x87, 0xbb);

    // 0x88 GAM14 : 0xd2 -> 0xd2
    this->set_and_verify(0x88, 0xd2);

    // 0x89 GAM15 : 0xe5 -> 0xe5
    this->set_and_verify(0x89, 0xe5);

    // 0x8c RGB444 : 0x00 -> 0x00
    // [0] RGB444 word format
    // [1] RGB444 enable (effective only when COM15[4]=1)
    this->set_and_verify(0x8c, 0x00);

    // 0x8d RSVD : 0xXX -> 0x4f
    this->set_and_verify(0x8d, 0x4f);

    // 0x8e RSVD : 0xXX -> 0x00
    this->set_and_verify(0x8e, 0x00);

    // 0x90 RSVD : 0xXX -> 0x00
    this->set_and_verify(0x90, 0x00);

    // 0x91 RSVD : 0xXX -> 0x00
    this->set_and_verify(0x91, 0x00);

    // 0x92 DM_LNL : 0x00 -> 0x00
    this->set_and_verify(0x92, 0x00);

    // 0x93 DM_LNH : 0x00 -> 0x00
    this->set_and_verify(0x93, 0x00);

    // 0x94 LCC6 : 0x50 -> 0x50
    this->set_and_verify(0x94, 0x50);

    // 0x95 LCC7 : 0x50 -> 0x50
    this->set_and_verify(0x95, 0x50);

    // 0x96 RSVD : 0xXX -> 0x00
    this->set_and_verify(0x96, 0x00);

    // 0x96 RSVD : 0xXX -> 0x00
    this->set_and_verify(0x96, 0x00);

    // 0x97 RSVD : 0xXX -> 0x30
    this->set_and_verify(0x97, 0x30);

    // 0x98 RSVD : 0xXX -> 0x20
    this->set_and_verify(0x98, 0x20);

    // 0x99 RSVD : 0xXX -> 0x30
    this->set_and_verify(0x99, 0x30);

    // 0x9a RSVD : 0xXX -> 0x84
    this->set_and_verify(0x9a, 0x84);

    // 0x9b RSVD : 0xXX -> 0x29
    this->set_and_verify(0x9b, 0x29);

    // 0x9c RSVD : 0xXX -> 0x03
    this->set_and_verify(0x9c, 0x03);

    // 0x9d BD50ST : 0x99 -> 0x4c
    this->set_and_verify(0x9d, 0x4c);

    // 0x9e BD60ST : 0x7f -> 0x3f
    this->set_and_verify(0x9e, 0x3f);

    // 0x9f HAECC1 : 0xc0 -> 0xc0
    this->set_and_verify(0x9f, 0xc0);

    // 0xa0 HAECC2 : 0x90 -> 0x90
    this->set_and_verify(0xa0, 0x90);

    // 0xa2 SCALING_PCLK_DELAY : 0x02 -> 0x02
    this->set_and_verify(0xa2, 0x02);

    // 0xa4 NT_CTRL : 0x00 -> 0x02
    // [1:0] Auto frame rate adjustment switch point
    // [3] Auto frame rate adjustment control
    this->set_and_verify(0xa4, 0x88);

    // 0xa5 BD50MAX: 0x0f -> 0x0f
    this->set_and_verify(0xa5, 0x0f);

    // 0xa6 HAECC3 : 0xf0 -> 0xf0
    this->set_and_verify(0xa6, 0xf0);

    // 0xa7 HAECC4 : 0xc1 -> 0xc1
    this->set_and_verify(0xa7, 0xc1);

    // 0xa8 HAECC5 : 0xf0 -> 0xf0
    this->set_and_verify(0xa8, 0xf0);

    // 0xa9 HAECC6 : 0xc1 -> 0xc1
    this->set_and_verify(0xa9, 0xc1);

    // 0xaa HAECC7 : 0x14 -> 0x14
    this->set_and_verify(0xaa, 0x14);

    // 0xab BD60MAX : 0x0f -> 0x0f
    this->set_and_verify(0xab, 0x0f);

    // 0xac STR-OPT : 0x00 -> 0x00
    this->set_and_verify(0xac, 0x00);

    // 0xad STR_R : 0x80 -> 0x80
    this->set_and_verify(0xad, 0x80);

    // 0xae STR_G : 0x80 -> 0x80
    this->set_and_verify(0xae, 0x80);

    // 0xaf STR_B : 0x80 -> 0x80
    this->set_and_verify(0xaf, 0x80);

    // 0xb0 RSVD : 0xXX -> 0x84
    this->set_and_verify(0xb0, 0x84);

    // 0xb1 ABLC1 : 0x00 -> 0x00
    this->set_and_verify(0xb1, 0x0c);

    // 0xb2 RSVD : 0xXX -> 0x0e
    this->set_and_verify(0xb2, 0x0e);

    // 0xb3 THL_ST : 0x80 -> 0x80
    this->set_and_verify(0xb3, 0x82);

    // 0xb5 THL_DLT : 0x04 -> 0x04
    this->set_and_verify(0xb5, 0x04);

    // 0xb8 RSVD : 0xXX -> 0x0a
    this->set_and_verify(0xb8, 0x0a);

    // 0xbe AD-CHB : 0x00 -> 0x00
    this->set_and_verify(0xbe, 0x00);

    // 0xbf AD-CHR : 0x00 -> 0x00
    this->set_and_verify(0xbf, 0x00);

    // 0xc0 AD-CHGb : 0x00 -> 0x00
    this->set_and_verify(0xc0, 0x00);

    // 0xc1 AD-CHGr : 0x00 -> 0x00
    this->set_and_verify(0xc1, 0x00);

    // 0xc8 RSVD : 0xXX -> 0xf0
    this->set_and_verify(0xc8, 0xf0);

    // 0xc9 SATCTR : 0xc0 -> 0x60
    this->set_and_verify(0xc9, 0x60);

	sccb.dump_log(pc);
    return;
}

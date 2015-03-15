# Introduction #

SerioのHW仕様検討

# Details #

  * 検討中のブロック図

![http://serio-pj.googlecode.com/svn/wiki/img/Architecture/Serio_SystemArch_20120509a.png](http://serio-pj.googlecode.com/svn/wiki/img/Architecture/Serio_SystemArch_20120509a.png)


  * DMAC含むFIFO側はFPGAの担当
  * それ以外はmbedが担当

## FPGA-MBed間の通信 ##
  * 候補1 Ethernet通信
  * 候補2 SPI通信
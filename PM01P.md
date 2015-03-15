# Introduction #

まな板の説明書など

# Details #

## mbed ##

  * VOUT: ブレッドボードの電源ラインにジャンプワイヤで接続
  * GND: ブレッドボードのGNDラインにジャンプワイヤで接続
  * VIN: マウスセンサの電源ラインにリボンケーブルで接続
  * p15: マウスセンサclk
  * p16: マウスセンサdata
  * p17: BIN1
  * p18: BIN2
  * p19: AIN1
  * p20: AIN2
  * p21: PWMA
  * p22: PWMB

![http://serio-pj.googlecode.com/svn/wiki/img/PM01P/mbed_pin_layout.png](http://serio-pj.googlecode.com/svn/wiki/img/PM01P/mbed_pin_layout.png)

## Mouse Sensor ##

  * 図の上部2か所のジャンパは赤い矢印のように接続
  * 下部配線は図の通りに接続。電源は5V
  * GNDはブレッドボードのGNDラインに接続

![http://serio-pj.googlecode.com/svn/wiki/img/PM01P/28560_connect.png](http://serio-pj.googlecode.com/svn/wiki/img/PM01P/28560_connect.png)

## Motor Driver ##

  * AO1/AO2にモータを1つ、BO1/BO2にモータを1つ接続
  * VMOTとGNDにモータ用の電源(6V)を接続
  * PWMAとPWMBは、それぞれmbedでは出せるピンが決まってる(p21-p26)ので注意

![http://serio-pj.googlecode.com/svn/wiki/img/PM01P/tb6612-assign.jpg](http://serio-pj.googlecode.com/svn/wiki/img/PM01P/tb6612-assign.jpg)

![http://serio-pj.googlecode.com/svn/wiki/img/PM01P/tb6612-sch.jpg](http://serio-pj.googlecode.com/svn/wiki/img/PM01P/tb6612-sch.jpg)
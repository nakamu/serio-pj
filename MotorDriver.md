# Introduction #

モーター選定、モータードライバについて

# Details #
  * PreAmp用バイポーラのデータシート
http://www2.famille.ne.jp/~teddy/tubes/image/c1815.pdf
  * モータードライバ
    * エミッタ接地でPreAmpを作る([ISSUE #2](https://code.google.com/p/serio-pj/issues/detail?id=#2))
      * pwm出力が0Vの時にモーターがONになるので注意

  * mbedのIOは4mAまで保証している。
    * 0.4V@4mA Dropするので、0.5mA位をターゲットにして各種抵抗値を決めることにする

  * mbedのIOで0.5mA流すということは、バイポーラのI(B)が0.5mAということ
  * データシートを見ると、I(B)=0.5mAの時のV(BE)は0.45V付近
    * 0.5mA流れた時に3.3 - 0.45 = 2.85V電圧を食うR1をmbedのIO->Base間に挿入すればよい。
    * 計算すると5.7kΩ（小さすぎるとmbedのIOを壊しかねない)

  * ON状態の時にV(CE)を小さくしたいので、コレクタ=>エミッタ間にあまり大きな電流は流せない。
  * データシートを見るとI(B)=0.5mAの時は、I(C)=40mAぐらいまでならほぼコレクタ=>エミッタ間の電圧Dropはない。
    * V(CE)=0と近似して、[R2](https://code.google.com/p/serio-pj/source/detail?r=2)\*40mA = 6.3VとなるR2をVCC->コレクタ間に挿入すれば良い。
      * 計算すると158Ω(これより大きいぶんには多分問題ない)


![http://serio-pj.googlecode.com/svn/wiki/img/Motor/MotorDriver.png](http://serio-pj.googlecode.com/svn/wiki/img/Motor/MotorDriver.png)

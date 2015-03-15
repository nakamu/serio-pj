# mbedオフラインコンパイル #

**arm-none-eabi-gccが必要になります．
## 環境の準備 (LINUX/MACユーザ) ##
  1. [このサイト](https://github.com/adamgreen/gcc4mbed) からzipでdownload．
  1. シェルを起動し，インストールの実行．
  1. arm-none-eabi-gccディレクトリができるので，そのディレクトリを適切なところに移動して，arm-none-eabi-gcc/bin以下にPATHを通す．**

> (注) mac信者は，macports経由でインストールすると，newlibがうまく動作しないので注意せよ．


## オフラインコンパイル手順 ##
  1. ターゲットのコードをmbedのCompilerサイトで開きます．
  1. [mbedのoffline-toolchainオブジェクト](http://mbed.org/users/mbed_official/code/mbed-export/)を，対象のコードにインポートして，従来のmbedオブジェクトは削除．
  1. GCC (Code Sourcery)でプログラムをエクスポート
  1. zipを解凍し，"make"コマンドを実行．
  1. "**.bin", "**.elf"ファイルが出来る．
### mt-dev

Movable Type の開発環境

### 動かしてみる

```
$ vagrant up
$ vagrant ssh
# 仮想環境
$ make -C mt-dev
$ make -C mt-dev exec-mysql SQL='CREATE DATABASE mt /*!40100 DEFAULT CHARACTER SET utf8 */'
```

http://192.168.7.25/cgi-bin/mt/mt.cgi を開くとインストール画面になる。デフォルトではaddonsもなしの https://github.com/movabletype/movabletype 。

### RECIPE

（これはまだ動かない）

バージョン番号での指定。
通常のQAではおそらくこれが主に使われる。

初回起動時にはベースになるURLを聞かれるので、以下を入力する。
https://sakk-qa.s3-ap-northeast-1.amazonaws.com/movabletype/recipe

```
# 仮想環境
$ make -C mt-dev RECIPE=7.2
```

### PACKAGE

（これは多分動く）

zipやtar.tzでの指定。
packageディレクトリにファイルを入れ、以下のように指定する。

```
# 仮想環境
$ make -C mt-dev PACKAGE=MT7-R4605.zip
```

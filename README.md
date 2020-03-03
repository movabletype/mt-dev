### mt-dev

Movable Type の開発環境

### 動かしてみる

```
$ vagrant up
$ vagrant ssh
# 仮想環境
$ cd mt-dev
$ make RECIPE=7.3
# yes/no を聞かれたら yes を答える
$ make exec-mysql SQL='CREATE DATABASE mt /*!40100 DEFAULT CHARACTER SET utf8 */'
```

http://192.168.7.25/cgi-bin/mt/mt.cgi を開くとインストール画面になる。デフォルトではaddonsもなしの https://github.com/movabletype/movabletype 。

### RECIPE

バージョン番号での指定。
通常のQAではおそらくこれが主に使われる。

初回起動時にはベースになるURLを聞かれるので、以下を入力する。
https://sakk-qa.s3-ap-northeast-1.amazonaws.com/movabletype/recipe

```
# 仮想環境
$ make RECIPE=7.3
```

### ARCHIVE

zipやtar.gzでの指定。
archiveディレクトリにファイルとパッチを入れ、以下のように指定する。

```
# 仮想環境
$ make ARCHIVE="MT7-R4605.zip a-patch.zip"
```

### その他

mt-config.cgi は、 mt-dev/mt-config.cgi （またはなければ mt-config.cgi-original）が使われる。

```
$ make up                                       # dafault
$ make up-psgi                                  # enable PSGI environment
$ make down                                     # stop MT
$ make down REMOVE_VOLUME=1                     # stop MT and remove all databases
$ make UP_ARGS=""                               # run in forground
$ make docker-compose ARGS="logs -f"            # execute docker-compose command
$ make MT_HOME_PATH="/home/vagrant/custom-mt"   # run custom-mt
$ make DOCKER_MT_IMAGE=custom-mt-docker-image
$ make DOCKER_MYSQL_IMAGE=mariadb:10.5.1-bionic # use MariaDB 10.5.1
```

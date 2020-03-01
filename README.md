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

バージョン番号での指定。
通常のQAではおそらくこれが主に使われる。

初回起動時にはベースになるURLを聞かれるので、以下を入力する。
https://sakk-qa.s3-ap-northeast-1.amazonaws.com/movabletype/recipe

```
# 仮想環境
$ make -C mt-dev RECIPE=7.2
```

### ARCHIVE

zipやtar.gzでの指定。
archiveディレクトリにファイルとパッチを入れ、以下のように指定する。

```
# 仮想環境
$ make -C mt-dev ARCHIVE="MT7-R4605.zip a-patch.zip"
```

### その他

mt-config.cgi は、 mt-dev/mt-config.cgi （またはなければ mt-config.cgi-original）が使われる。

```
$ make -C mt-dev up                                       # dafault
$ make -C mt-dev up-psgi                                  # enable PSGI environment
$ make -C mt-dev down                                     # stop MT
$ make -C mt-dev down REMOVE_VOLUME=1                     # stop MT and remove all databases
$ make -C mt-dev UP_ARGS=""                               # run in forground
$ make -C mt-dev docker-compose ARGS="logs -f"            # execute docker-compose command
$ make -C mt-dev MT_HOME_PATH="/home/vagrant/custom-mt"   # run custom-mt
$ make -C mt-dev DOCKER_MT_IMAGE=custom-mt-docker-image
$ make -C mt-dev DOCKER_MYSQL_IMAGE=mariadb:10.5.1-bionic # use MariaDB 10.5.1
$ make -C mt-dev DOCKER_MEMCACHED_IMAGE=busybox           # memcached is stopped
```

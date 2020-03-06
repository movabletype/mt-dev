### mt-dev

Movable Type の開発環境

### 必要なもの

* Git
* Vagrant
* VirtualBox

### 動かしてみる

```
$ vagrant mt-dev check-ssh-key
# OK! と出なかったら https://github.com/movabletype/mt-dev/wiki/Troubleshooting へ
$ vagrant mt-dev up RECIPE=7.3
# Please input base URL of recipe data と聞かれたら https://sakk-qa.s3-ap-northeast-1.amazonaws.com/movabletype/recipe を入力
# 完了後、20秒ほど待つ（mysqlの起動に時間がかかる）
$ vagrant mt-dev exec-mysql SQL='CREATE DATABASE mt /*!40100 DEFAULT CHARACTER SET utf8 */'
```

http://192.168.7.25/cgi-bin/mt/mt.cgi を開くとインストール画面になる。上のコマンドでは7.3で起動（CGI版）

### RECIPE

バージョン番号での指定。
通常のQAではおそらくこれが主に使われる。

初回起動時にはベースになるURLを聞かれるので、以下を入力する。
https://sakk-qa.s3-ap-northeast-1.amazonaws.com/movabletype/recipe

```
$ vagrant mt-dev up RECIPE=7.3
```

### ARCHIVE

zipやtar.gzでの指定。
archiveディレクトリにファイルとパッチを入れ、以下のように指定する。

```
$ vagrant mt-dev up ARCHIVE="MT7-R4605.zip a-patch.zip"
```

### その他

mt-config.cgi は、 mt-dev/mt-config.cgi （またはなければ mt-config.cgi-original）が使われる。

```
$ vagrant mt-dev up                                          # dafault
$ vagrant mt-dev up-psgi                                     # enable PSGI environment
$ vagrant mt-dev down                                        # stop MT
$ vagrant mt-dev down REMOVE_VOLUME=1                        # stop MT and remove all databases
$ vagrant mt-dev up UP_ARGS=""                               # run in forground
$ vagrant mt-dev docker-compose ARGS="logs -f"               # execute docker-compose command
$ vagrant mt-dev up MT_HOME_PATH="/home/vagrant/custom-mt"   # run custom-mt
$ vagrant mt-dev up DOCKER_MT_IMAGE=custom-mt-docker-image
$ vagrant mt-dev up DOCKER_MYSQL_IMAGE=mariadb:10.5.1-bionic # use MariaDB 10.5.1
```

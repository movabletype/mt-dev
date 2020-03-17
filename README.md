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


### Development

#### VSCode

You can edit codes using "Visual Studio Code Remote Development".

1. `$ vagrant mt-dev publish-ssh-config`
    * "${mt-dev-dir}/.ssh-config" has been generated.
1. Open "mt-dev" ssh target in VSCode with "${mt-dev-dir}/.ssh-config".

### sshfs

1. `$ vagrant mt-dev publish-ssh-config`
    * "${mt-dev-dir}/.ssh-config" has been generated.
1. `$ sshfs -F ${PWD}/.ssh-config mt-dev:. src`
1. Edit src/path/to/file

### トピックブランチの維持

デフォルトでは `$ vagrant mt-dev up RECIPE=...` を実行する度に指定されたブランチの最新に更新される。トッピックブランチを作成して作業している場合には、 `UPDATE_BRANCH=no` を指定するとブランチの更新がスキップされる。

```
$ vagrant mt-dev up RECIPE=7.3 UPDATE_BRANCH=no
```

後述する .env ファイルに `UPDATE_BRANCH=no` を記述する形でもよい。.env ファイルで `UPDATE_BRANCH=no` を指定しているが、ブランチの更新も行いたい場合には `UPDATE_BRANCH=yes` を明示的に指定することで更新することができる。


```
$ vagrant mt-dev up RECIPE=6.x UPDATE_BRANCH=yes
```

### .env ファイルの利用

オプションが多くてファイルで管理したい場合には .env ファイルを利用できる。

```
$ cat .env
ARCHIVE=MT7-R4605.zip
RECIPE=mt-plugin-MyAwsomePlugin
MT_CONFIG_CGI=mt-config.cgi-local
$ vagrant mt-dev up-psgi
$ # または vagrant mt-dev up-psgi ENV_FILE=.env
```

### `make` の実行による起動

以下の環境が整っているLinuxやMacでは `vagrant mt-dev` を `make` に置き換えてローカル環境上で直接起動することもできる。

* make コマンド
* perl
    * HTTP::Tiny
      * IO::Socket::SSL などが入って https にリクエストできること
* Docker環境
    * Docker for Macも可

```
$ make up-psgi ARCHIVE=MT7-R4605.zip RECIPE=mt-plugin-MyAwsomePlugin MT_CONFIG_CGI=mt-config.cgi-local
```

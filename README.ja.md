### mt-dev

Movable Typeの開発環境です。

VagrantとDockerの環境が利用できます。Vagrantの方を標準としてサポートおり、どのOS上でもMTの動作が高速で安定しています。Dockerを直接利用できる環境の場合にはVagrantを介すことなくDockerで起動でき、こちらの方が開発との相性はよいです。

### 必要なもの

#### Vagrant環境

* Git
* Vagrant
    * 2.2.x以降のバージョン
* VirtualBox

#### Docker環境

* Git
* Docker

### サポートしているOS

* Windows
* macOS
    * Catalinaの場合は[wiki](https://github.com/movabletype/mt-dev/wiki/Troubleshooting#macos-catalina)を参照してください
* Linux
    * Docker環境で利用するのがおすすめです

### 動かしてみる

```
$ git clone git@github.com:movabletype/mt-dev.git mt-dev
$ cd mt-dev
$ cp /path/to/MT7-R0000.zip archive/
$ vagrant mt-dev up ARCHIVE=MT7-R0000.zip
$ vagrant mt-dev exec-mysql SQL='CREATE DATABASE mt /*!40100 DEFAULT CHARACTER SET utf8mb4 */'
```

http://192.168.7.25/cgi-bin/mt/mt.cgi を開くとインストール画面になります。

mt-config.cgiは、mt-dev/mt-config.cgi（またはなければmt-config.cgi-original）が使われます。


### その他の主な起動オプション

```
$ vagrant mt-dev up ARCHIVE=MT.tar.gz
$ vagrant mt-dev up-psgi ARCHIVE=MT.tar.gz     # PSGI環境で起動
$ vagrant mt-dev down                          # MTを停止
$ vagrant mt-dev down REMOVE_VOLUME=1          # MTを停止してデータベースのデータを削除
$ vagrant mt-dev up UP_ARGS=""                 # MTコンテナをforgroundで起動
$ vagrant mt-dev docker-compose ARGS="logs -f" # ログの表示
$ vagrant mt-dev up PERL=5.28 PHP=7.3          # PerlやPHPのバージョンを指定
$ vagrant mt-dev up DB=mariadb:10.5.1-bionic   # MariaDB 10.5.1を利用する
```

### プラグインの参照

repo以下にMovable Typeの一般的なディレクトリ構成のプラグインを置き、ディレクトリ名をREPOとして指定すると、そのプラグインがインストールされた状態で起動されます。

```
$ git clone git@github.com:movabletype/mt-plugin-shared-preview.git repo/mt-plugin-shared-preview
$ vagrant mt-dev up ARCHIVE=MT.tar.gz REPO=mt-plugin-shared-preview
```

gitのURLを直接指定することもできます。

```
$ vagrant mt-dev up ARCHIVE=MT.tar.gz REPO=git@github.com:movabletype/mt-plugin-shared-preview.git
```

REPOで指定してPSGI環境で起動した場合、プラグインのファイルをローカル環境で更新しても即座には反映されません。PSGIのプロセスを明示的に再起動する必要があります。

### .env ファイルの利用

オプションが多くてファイルで管理したい場合には .env ファイルを利用できます。

```
$ cat .env
ARCHIVE=MT7.zip
REPO=git@github.com:movabletype/mt-plugin-shared-preview.git
MT_CONFIG_CGI=mt-config.cgi-local
$ vagrant mt-dev up
$ # または vagrant mt-dev up ENV_FILE=.env
```

### Docker環境での起動

以下の環境が整っている場合には `vagrant mt-dev` を `make` に置き換えてローカル環境上で直接起動することができます。

* make コマンド
* perl
    * HTTP::Tiny
      * IO::Socket::SSL などが入って https にリクエストできること
* Docker環境
    * Docker for Macも可

```
$ make up ARCHIVE=MT7-R4605.zip RECIPE=mt-plugin-MyAwsomePlugin MT_CONFIG_CGI=mt-config.cgi-local
```

### 開発

#### VSCode

"Visual Studio Code Remote Development"を使って以下のように開発することができます。

1. `$ vagrant mt-dev publish-ssh-config`
    * "${mt-dev-dir}/.ssh-config" has been generated.
1. Open "mt-dev" ssh target in VSCode with "${mt-dev-dir}/.ssh-config".

### sshfs

sshfsは以下のように利用できます。

1. `$ vagrant mt-dev publish-ssh-config`
    * "${mt-dev-dir}/.ssh-config" has been generated.
1. `$ sshfs -F ${PWD}/.ssh-config mt-dev:. src`
1. Edit src/path/to/file

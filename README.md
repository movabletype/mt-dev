### mt-dev

This is the Movable Type development environment.

You can use both Vagrant and Docker environments. Vagrant is default environment and is faster and more stable on any OS. If you have direct access to Docker, you can use Docker without going through Vagrant. It can be launched.


### Requirements

#### Vagrant environment

* Git
* Vagrant
    * ( 2.2.x or later )
* VirtualBox

#### Docker environment

* Git
* Docker

### Supported operating systems

* Windows
* macOS
* Linux
    * Recommended to use in Docker environment

### Getting started

```
$ cp /path/to/MT7-R0000.zip archive/
$ vagrant mt-dev up ARCHIVE=MT7-R0000.zip
$ vagrant mt-dev exec-mysql SQL='CREATE DATABASE mt /*!40100 DEFAULT CHARACTER SET utf8mb4 */'
```

Open http://192.168.7.25/cgi-bin/mt/mt.cgi .

mt-config.cgi will use mt-dev/mt-config.cgi (or mt-config.cgi-original if none).

### Options

```
$ vagrant mt-dev up ARCHIVE=MT.tar.gz
$ vagrant mt-dev up-psgi ARCHIVE=MT.tar.gz     # launch MT with PSGI environment
$ vagrant mt-dev down                          # stop MT
$ vagrant mt-dev down REMOVE_VOLUME=1          # stop MT and remove database.
$ vagrant mt-dev up UP_ARGS=""                 # launch MT container in forground
$ vagrant mt-dev docker-compose ARGS="logs -f" # show logs
$ vagrant mt-dev up PERL=5.28 PHP=7.3          # specify versions of Perl, PHP
$ vagrant mt-dev up DB=mariadb:10.5.1-bionic   # specify MariaDB 10.5.1
```

### Using plugins

If you put a plugin of Movable Type's general directory structure under repo and specify the directory name as REPO, that plugin will be installed and started.

```
$ git clone git@github.com:movabletype/mt-plugin-shared-preview.git repo/mt-plugin-shared-preview
$ vagrant mt-dev up ARCHIVE=MT.tar.gz REPO=mt-plugin-shared-preview
```

You can also specify the git URL directly.

```
$ vagrant mt-dev up ARCHIVE=MT.tar.gz REPO=git@github.com:movabletype/mt-plugin-shared-preview.git
```

If you specify it in REPO and start it in the PSGI environment, even if you update the plugin file in the local environment, it will not be reflected immediately. PSGI process needs to be restarted explicitly

### Using .env file

If you have many options and want to manage them in a file, you can use the .env file.

```
$ cat .env
ARCHIVE=MT7.zip
REPO=git@github.com:movabletype/mt-plugin-shared-preview.git
MT_CONFIG_CGI=mt-config.cgi-local
$ vagrant mt-dev up
$ # Or vagrant mt-dev up ENV_FILE=.env
```

### Launch with Docker environment

If you have the following environment, you can replace `vagrant mt-dev` with `make` and start it directly in your local environment.

* make command
* perl
    * HTTP::Tiny
* Docker environment
    * You can also use Docker for Mac

```
$ make up ARCHIVE=MT7-R4605.zip RECIPE=mt-plugin-MyAwsomePlugin MT_CONFIG_CGI=mt-config.cgi-local
```

### Environment

#### VSCode

You can use "Visual Studio Code Remote Development" to develop as follows.

1. `$ vagrant mt-dev publish-ssh-config`
    * "${mt-dev-dir}/.ssh-config" has been generated.
1. Open "mt-dev" ssh target in VSCode with "${mt-dev-dir}/.ssh-config".

### sshfs

You can use sshfs as follows.

1. `$ vagrant mt-dev publish-ssh-config`
    * "${mt-dev-dir}/.ssh-config" has been generated.
1. `$ sshfs -F ${PWD}/.ssh-config mt-dev:. src`
1. Edit src/path/to/file

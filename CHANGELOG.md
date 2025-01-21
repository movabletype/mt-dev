# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

* Make the generated certificate readable by any MySQL server.

### Fixed

* Fix permission issue of mysql conf.d directory.
  * Remove write permission because it is an error in environments where write permission is added to other by default.

## [2.7.0] - 2024-11-15

### Added

* Added support for mysql:9.x docker images.
* Enable to use SSL connection to MySQL.

### Changed

* Update default image version.
  * Perl: 5.38
  * PHP: 8.3
  * Node.js: 20.17.1
* Remove "version" as it is no longer needed in docker compose v2.

## [2.6.0] - 2024-08-30

### Changed

Changed the base image to "bento/ubuntu-24.04" when booting via `Vagrant mt-dev`.

To update, you must delete the virtual machine with `vagrant destroy` and then start it again. Removing the virtual machine
will result in the loss of all database data. If you do not update, you can continue to use 2.5.1 and there is no feature
difference at this time.

## [2.5.1] - 2024-08-30

### Security

* Install cpan modules from https://www.cpan.org

### Added

* Add mt/mailpit.yml

Enable to start MailPit service by the following command.
```
$ make up-psgi DOCKER_COMPOSE_USER_YAML="-f mt/mailpit.yml"
```

## [2.5.0] - 2023-02-15

### Added

* Enable to specify build command for each plugin

```
mt-plugin-MTBlockEditor:
  location: git@github.com:movabletype/mt-plugin-MTBlockEditor
  branch: develop
  build:
    command:
      - docker-compose
      - run
      - builder
      - bash
      - -c
      - 'perl Makefile.PL && make build'
```

## [2.4.0] - 2023-11-25

### Changed

### Fixed

* Run `CREATE DATABASE IF NOT EXISTS` only when `Database` is specified in `mt-config.cgi`.

#### The command line has priority over the recipe

As shown below, when "archive" is specified by a recipe and "ARCHIVE" is specified by a command line at the same time, the command line has priority over the recipe.

```yaml
mt-plugin-MTBlockEditor:
  archive:
    url: https://github.com/movabletype/mt-plugin-MTBlockEditor/releases/download/v1.1.10/MTBlockEditor-1.1.10.tar.gz
    integrity: sha512-VCrI5B/cv4FAEV7O9GPOsJGEATwRcw4GqjVCWZiMPSkC9jx2l0kjnTXl6M2Xvv/x6THnPQj9VgxX9B0MG7a25g==
```

```
$ make up RECIPE=8.0.0-dp ARCHIVE=MTBlockEditor-1.1.11.tar.gz
```

#### Enable to expose port from "mt" container

In "mt" container, "httpd" or "psgi" listens on port 80, so specifying MT_EXPOSE_PORT will allow access to port 80 of the "mt" container from the port number specified in the host environment MT_EXPOSE_PORT.

```
$ make up-psgi MT_EXPOSE_PORT=5002
```

## [2.3.2] - 2023-07-18

### Fixed

* Fix compatibility issue, again.

## [2.3.1] - 2023-07-18

### Fixed

* mt-dev now works in environments with Digest modules older than 1.17.

## [2.3.0] - 2023-07-13

### Added

* Introduce UPDATE_DOCKER_IMAGE environment variable.
    * Setting this environment variable to "no" will skip updating the Docker image during `make up`.
* ARCHIVE can now be specified in the recipe yaml file.
    * Specify url and integrity in the following format

```yaml
mt-plugin-MTBlockEditor:
  archive:
    url: https://github.com/movabletype/mt-plugin-MTBlockEditor/releases/download/v1.1.10/MTBlockEditor-1.1.10.tar.gz
    integrity: sha512-VCrI5B/cv4FAEV7O9GPOsJGEATwRcw4GqjVCWZiMPSkC9jx2l0kjnTXl6M2Xvv/x6THnPQj9VgxX9B0MG7a25g==
```

### Changed

* Refactored Dockerfile for mt-watcher.
    * Ensure that binaries with the appropriate architecture are installed even if BuildKit is disabled.
    * Reduced image size by using "perl:*-slim" images.

### Fixed

* Add workaround to run amd64 image on arm64.

## [2.2.0] - 2023-02-15

### Added

* Can now be lunched in an arm64 environment.

## [2.1.2] - 2022-08-24

### Fixed

* Ignore errors when deleting temporary files.
* Use the `--pull` option to always use the latest image.
* Accept "/" and "-" in branch names specified in `REPO`.

## [2.1.1] - 2022-06-20

### Fixed

* Fixed an error with old docker-compose.

## [2.1.0] - 2022-06-18

### Added

* Added support for specifying the cpanfile to be referenced at startup with DOCKER_MT_CPANFILES.
    * The default value is t/cpanfile.
* CGIPath and StaticWebPath can now be specified relative to the host.
* The database specified in mt-config.cgi is now automatically created if it does not exist.
    * If you do not want to create it automatically, you can skip this behavior by specifying `CREATE_DATABASE_IF_NOT_EXISTS=no`.
* In the Vagrant environment, we have added a setting to forward the host's port to the guest.
    * The default value is 5825, which can be accessed at http://localhost:5825/cgi-bin/mt/mt.cgi.
    * You can change this value with the `VM_VB_HTTP_PORT` or `HTTPD_EXPOSE_PORT` environment variables.

## [2.0.0] - 2022-02-21

### Added

#### Customized Docker containers

You can launch the container with customizations of your choice.
And the development container configuration for Visual Studio Code is included by default.

```
$ make up-psgi ... DOCKER_MT_DOCKERFILE=Dockerfile.devcontainer REPO="$HOME/src/github.com/username/mt-plugin-AwesomePlugin"
```

#### Support mount flag (especially for Docker for Mac)

Docker for Mac has slow file access on bind mounts, but if you use a dev container, using :delegated may improve the situation.

```
$ make up-psgi ... DOCKER_VOLUME_MOUNT_FLAG=delegated
```

### Changed

* Also skip `git fetch` when "$UPDATE_BRANCH" is "no".
* Rename environment variable DOCKER_COMPOSE_YML_MIDDLEWARES to DOCKER_COMPOSE_YAML_MIDDLEWARES

## [1.1.1] - 2022-01-03

### Changed

* Change default private network.

### Added

* Enable to start service via.
    * e.g. DOCKER\_MT\_SERVICES=postfix
* Support docker-compose 2.x

### Fixed

* Also watch the plugin directory specified by REPO.

## [1.1.0] - 2021-07-13

### Changed

#### Removed some options for starman

* Stop passing the -R option
    * https://metacpan.org/dist/Starman/view/script/starman#RELOADING-THE-APPLICATION
* Stop passing the "-L Shotgun", because it is different from the option in general production environment.

#### New file monitoring container

* Added a container to monitor file updates and send a HUP signal to starman.

[Details](https://github.com/movabletype/mt-dev/wiki/Architecture#mt-watcher)


## [1.0.7] - 2021-07-02

### Added

* Enable mod\_include by default.
    * You can use SSI just choose "Apache Server-Side Include" in MT.

### Fixed

* Improved stability when REPO is specified.

## [1.0.6] - 2021-05-20

### Added

* Enable to use both RECIPE and ARCHIVE at the same time
    * e.g. RECIPE=7.8.0 ARCHIVE="https://github.com/movabletype/mt-plugin-MTBlockEditor/releases/download/v0.0.17-beta/MTBlockEditor-0.0.17-beta.tar.gz"

### Fixed

* Fixed a bug when downloading multiple archives.

## [1.0.5] - 2021-05-19

### Added

* Also link automatically "tools/*" of each plugins.
* Enable to override branch by REPO
    * e.g. REPO="git@github.com:movabletype/movabletype#topic-branch"

### Fixed

* Also prevent running `make clean me` when `UPDATE_BRANCH=no` is specified.
* Invoke `apt` with DEBIAN_FRONTEND=noninteractive in provisioning.

## [1.0.4] - 2021-01-13

### Added

* Enable to specify branch by "#" in REPO
    * e.g. REPO="https://github.com/user/mt-plugin-XXX.git#main"
* Enable to specify branch by PR parameter
    * e.g. PR="https://github.com/movabletype/movabletype/pull/1527"

## [1.0.3] - 2020-10-22

### Added

* Support relative CGIPath/StaticWebPath.
* Specify NLS_LANG for suppoting Oracle Database.

## [1.0.2] - 2020-10-15

### Fixed

* __BUILD_ID__ is now updated every time.

## [1.0.1] - 2020-08-27

### Added

* Bind mt-dev directory to /mt-dev.

## [1.0.0] - 2020-06-22

### Changed

* Use movabletype/test instead of movabletype/dev for docker image.

### Removed

* We don't need to build php-5.3 as it can be verified on CentoOS 6.

## [0.0.11] - 2020-05-16

### Changed

* Renewal local-repo feature as repo feature.

### Added

* Enable to specify GIT URL to REPO variable.
* Enable to specify ARCHIVE URL to ARCHIVE variable.

## [0.0.10] - 2020-05-16

### Changed

* Removed "init-repo" target that doesn't needed.
* Renewal ext-repos feature as local-repo feature.

## [0.0.9] - 2020-05-15

### Added

* Added support for prefixed themes/plugin in the repository

## [0.0.8] - 2020-05-13

### Added

* Add ext-repos feature.
* Add cpan-install / cpan-uninstall command
* Add cp-R command

### Fixed

* Avoid errors in theme export

## [0.0.7] - 2020-04-16

* Extend timeout for waiting response from MT at httpd.
* Fix typo.

## [0.0.6] - 2020-04-01

### Added

* Support shourtcut for perl/php/db docker image.

## [0.0.5] - 2020-04-01

### Added

* Enable to invoke ./tools/*.pl by `vagrant mt-dev mt-shell`.

### Changed

* Improve packup command wrapper.
* Execute /usr/sbin/php-fpm on httpd container if available.
* Use NFS for synced_folder on Mac.
* Invoke `docker-compose pull` before each `docker-compose up`.
* Invoke `make me` before run.

## [0.0.4] - 2020-03-17

### Added

* Enable to keep the current branch.

### Fixed

* Tweaks .env file feature.

## [0.0.3] - 2020-03-16

### Added

* Support VSCode Remote Development

### Changed

* Run starman with the auto reload option.

## [0.0.2] - 2020-03-11

### Added

* Enable to specify both RECIPE and ARCHIVE.
  * `$ vagrant mt-dev up ARCHIVE=MTA7-R4605.tar.gz RECIPE=shared-preview`

### Changed

* Update default software versions.
  * Perl : 5.28
  * PHP : 7.3
  * DB : MySQL 5.7

## [0.0.1] - 2020-03-09

### Added

* Support multiple recipes.
  * `$ vagrant mt-dev up RECIPE=7.2,shared-preview`
* Support custom mt-config.cgi
  * `$ vagrant mt-dev up RECIPE=7.2 MT_CONFIG_CGI=mt-config.cgi-7.2`

### Fixed

* Fix repository pull bug.

## [0.0.0] - 2020-03-02

Initial release

# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

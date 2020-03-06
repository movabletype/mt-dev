# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

#!/bin/bash
set -x

sudo apt update
sudo apt install -y make git zip cpanminus perltidy libio-socket-ssl-perl
sudo cpanm --force --from https://www.cpan.org App::cpm
sudo apt clean

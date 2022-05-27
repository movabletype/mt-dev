#!/bin/bash
set -xe

sudo apt update
sudo apt install -y make git zip libio-socket-ssl-perl
sudo apt clean

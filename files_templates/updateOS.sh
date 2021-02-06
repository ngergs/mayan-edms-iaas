#!/bin/bash
#updates
apt-get update
apt-get -y upgrade
#dist-upgrade may involve interactions for kernel-updates
apt-get -y dist-upgrade
apt-get -y autoremove

#!/bin/bash
set -eux

apt-get update
apt-get install -y nginx
systemctl enable nginx
systemctl restart nginx

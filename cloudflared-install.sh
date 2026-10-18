#!/bin/bash

# Add cloudflared.repo to /etc/yum.repos.d/
curl -fsSl https://pkg.cloudflare.com/cloudflared-ascii.repo | sudo tee /etc/yum.repos.d/cloudflared.repo

# update repo
sudo yum update

# install cloudflared
sudo yum install cloudflared

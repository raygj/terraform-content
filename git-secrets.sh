#!/bin/sh
# run on root of repo after initialize/clone so hooks can be written to .git
#
git secrets --install -f
git secrets --register-aws

# run manual scan against /GitHub
git secrets --scan -r /Users/jray/Documents/GitHub/
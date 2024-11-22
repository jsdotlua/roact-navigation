#!/bin/sh

set -e

rm -rf build/wally

yarn dlx npmwally convert --output build/wally

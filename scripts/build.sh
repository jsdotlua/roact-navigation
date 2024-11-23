#!/bin/sh

set -e

./scripts/build-roblox-model.sh .darklua.json roact-navigation.rbxm
./scripts/build-roblox-model.sh .darklua-dev.json debug/roact-navigation.rbxm

./scripts/build-wally-package.sh

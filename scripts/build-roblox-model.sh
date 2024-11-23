#!/bin/sh

set -e

DARKLUA_CONFIG=$1
OUTPUT=build/$2

rm -rf temp

mkdir -p temp

cp -r src/ temp/
./scripts/remove-tests.sh temp

rojo sourcemap model.project.json -o sourcemap.json

darklua process --config $DARKLUA_CONFIG node_modules temp/node_modules

cp $DARKLUA_CONFIG temp/
cp sourcemap.json temp/

darklua process --config temp/$DARKLUA_CONFIG temp/src temp/src

./scripts/remove-tests.sh temp

cp model.project.json temp/

mkdir -p build
mkdir -p $(dirname $OUTPUT)

rojo build temp/model.project.json -o $OUTPUT

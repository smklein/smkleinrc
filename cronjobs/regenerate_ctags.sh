#!/bin/bash

cd ~/ssd/mojo/src/
rm -f tags
ctags --exclude=*.js --exclude=*.dart --exclude=*.tex --exclude=*.pyx --exclude=*.yaml -R .

cd ~/ssd/nacl/native_client/
rm -f tags
ctags --exclude=*.js --exclude=*.dart --exclude=*.tex --exclude=*.pyx --exclude=*.yaml -R .

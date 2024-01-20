#!/bin/bash

set -e

sudo docker run --rm \
       	--volume "$(pwd):/data" \
       	--user $(id -u):$(id -g) \
       	nightkeeper:v1 test.md -o test.pdf --template eisvogel \
       	--listings \
	-V titlepage="true" \
    -V titlepage-text-color="FFFFFF" \
    -V titlepage-rule-color="360049" \
    -V titlepage-rule-height=0 \
    -V titlepage-background="background.pdf" \
    -V author="lihao.lei" \
    -V date="80000000-ETD-ENG-01-20240121" \
    -V titlepage-logo="logo.pdf" \
    -V logo-width="30mm"


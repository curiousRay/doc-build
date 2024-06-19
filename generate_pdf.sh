#!/bin/bash

set -e

sudo docker run --rm \
       	--volume "$(pwd):/data" \
       	--user $(id -u):$(id -g) \
       	nightkeeper:v1 doc.md \
		--lua-filter "doc-build-assets/preprocess.lua" \
        --from=markdown-markdown_in_html_blocks \
		 > /dev/null
	
sudo docker run --rm \
       	--volume "$(pwd):/data" \
       	--user $(id -u):$(id -g) \
       	nightkeeper:v1 doc.md -o doc.pdf --template doc-build-assets/eisvogel.tex \
        --toc \
        --toc-depth=5 \
       	--listings \
        --pdf-engine "xelatex" \
		--lua-filter "doc-build-assets/preprocess.lua" \
        --lua-filter "doc-build-assets/filter.lua" \
        --from=markdown-markdown_in_html_blocks \
        --number-sections \
        --filter pandoc-latex-environment \
    -V table-use-row-colors \
    -V lang="zh-CN" \
    -V CJKmainfont="Source Han Sans SC" \
	-V titlepage="true" \
    -V titlepage-text-color="FFFFFF" \
    -V titlepage-rule-color="360049" \
    -V titlepage-rule-height=0 \
    -V titlepage-background="doc-build-assets/background.pdf" \
    -V author="lihao.lei" \
    -V author-meta="lihao.lei" \
    -V title-meta="Instruction For Use" \
    -V date="80000000-ETD-ENG-01-20240121" \
    -V titlepage-logo="doc-build-assets/logo.pdf" \
    -V logo-width="30mm" \
    -V toc-own-page="true" \
    -V geometry:top="2.5cm" \
    -V geometry:bottom="2.5cm" \
    -V geometry:left="1.5cm" \
    -V geometry:right="1.5cm" \
    -V colorlinks="true"

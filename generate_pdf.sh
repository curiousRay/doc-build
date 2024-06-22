#!/bin/bash

set -e

src_docfile_root="doc.md" # change the relative path/name to source docfile (*.md) on your need
dst_docfile_root="doc.pdf" # change the relative path/name to destination docfile (*.pdf) on your need
src_resource_root="./" # relative path to the image resource directory

sudo docker run --rm \
       	--volume "$(pwd):/data" \
       	--user $(id -u):$(id -g) \
		nightkeeper/doc-build:latest $src_docfile_root \
		--lua-filter "doc-build-assets/preprocess.lua" \
		--verbose \
		-V resource-path=$src_resource_root \
		 > /dev/null
	
sudo docker run --rm \
       	--volume "$(pwd):/data" \
       	--user $(id -u):$(id -g) \
		nightkeeper/doc-build:latest $src_docfile_root -o $dst_docfile_root --template doc-build-assets/eisvogel.tex \
        --toc \
        --toc-depth=5 \
       	--listings \
        --pdf-engine "xelatex" \
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

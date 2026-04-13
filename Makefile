SHELL := /usr/bin/env bash

PROJECT_ROOT := $(CURDIR)
RSCRIPT := Rscript
MAIN_TEX := manuscript/main.tex
TARGET ?=

.PHONY: all data one paper normalize-bib restore snapshot clean clean-cache

all: data paper

data:
	$(RSCRIPT) -e 'targets::tar_make()'

one:
	@test -n "$(TARGET)" || (echo "Set TARGET=<target_name>." && exit 1)
	$(RSCRIPT) -e 'targets::tar_make(names = "$(TARGET)")'

paper:
	cd manuscript && latexmk -pdf -interaction=nonstopmode -halt-on-error main.tex

normalize-bib:
	$(RSCRIPT) -e 'source("R/normalize-bib.R"); normalize_references("manuscript/references.bib")'

restore:
	$(RSCRIPT) -e 'renv::restore(prompt = FALSE)'

snapshot:
	$(RSCRIPT) -e 'renv::snapshot(prompt = FALSE)'

clean:
	cd manuscript && latexmk -c main.tex

clean-cache:
	rm -rf _targets
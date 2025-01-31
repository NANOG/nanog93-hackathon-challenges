# -*- mode: makefile; fill-column: 78; comment-column: 50; tab-width: 2 -*-

# get the rood directory of the Makefile
ROOT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

.PHONY: all
all:
## all: create the final build product
	build-dockerfile

# i always set this to .PHONY in the event that there's a "clean" file
.PHONY: clean
clean:
## clean: whack all targets
	docker image rm nanog92-ubuntu:latest

build-dockerfile:
## build-dockerfile: generate the docker image
	docker build -t nanog92-ubuntu:latest .

network-01-up:
## network-01-up: startup network-01
	cd network-01 && \
		sudo containerlab deploy -t network-01.yml && \
		sudo ./score-challenge.sh list-routes

network-01-down:
## network-01-down: tear down network-01
	cd network-01 && \
		sudo containerlab destroy -t network-01.yml

network-01-baseline-up:
## network-01-baseline-up: startup network-01 (baseline config)
	cd network-01-baseline && \
		sudo containerlab deploy -t network-01.yml && \
		sudo ../network-01/score-challenge.sh list-routes

network-01-baseline-down:
## network-01-baseline-down: tear down network-01 (baseline config)
	cd network-01-baseline && \
		sudo containerlab destroy -t network-01.yml

install-gnmic:
## install-gnmic: installs the latest gnmic client to /usr/local/bin
	curl -sL https://get-gnmic.openconfig.net | bash

.PHONY: help
help:
## help: prints this help message
	@echo "usage: \n"
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' |  sed -e 's/^/ /'

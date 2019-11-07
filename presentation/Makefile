###############################################################################
# file    : Makefile                                                          #
# purpose : file for automating docker actions                                #
#                                                                             #
# author  : Harald van der Laan                                               #
# date    : 2018/oct/20                                                       #
# version : v1.0.0                                                            #
###############################################################################
# License: MIT                                                                #
# Copyright © 2018, harald van der laan                                       #
#                                                                             #
# Permission is hereby granted, free of charge, to any person obtaining       #
# a copy of this software and associated documentation files (the "Software"),#
# to deal in the Software without restriction, including without limitation   #
# the rights to use, copy, modify, merge, publish, distribute, sublicense,    #
# and/or sell copies of the Software, and to permit persons to whom the       #
# Software is furnished to do so, subject to the following conditions:        #
#                                                                             #
# The above copyright notice and this permission notice shall be included     #
# in all copies or substantial portions of the Software.                      #
#                                                                             #
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,             #
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES             #
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.   #
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, #
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,               #
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE  #
# OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                               #
###############################################################################

.PHONY: all run stop
.DEFAULT_GOAL := help

SHELL = /bin/bash
APP = 'presentation'
PWD = $(shell pwd)

all: run ## building and running Node server container

help:
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

run: ## deploying the node js  container
	@docker run --name $(APP) -v "$(PWD)":/revealjs/md -p 8000:8000 -d gamsd/revealjs-md

stop: ## stopping the node js container
	@docker rm $(APP) -f

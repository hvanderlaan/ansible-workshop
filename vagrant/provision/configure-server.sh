#!/usr/bin/env bash

# =========================================================================== #
# File     : configure-server.sh                                              #
# Purpose  : Provision script for vagrant test server                         #
#                                                                             #
# Author   : Harald van der Laan <harald.van.der.laan@anylinq.com>            #
# Date     : 2019-11-01                                                       #
# Version  : v1.0.0                                                           #
# =========================================================================== #
# Changelog:                                                                  #
#  - v1.0.0: Initial version                            (Harald van der Laan) #
# =========================================================================== #
# License  : MIT                                                              #
# Copyright (c) 2019, Harald van der Laan                                     #
#                                                                             #
# Permission is hereby granted, free of charge, to any person obtaining a     #
# copy of this software and associated documentation files (the "Software"),  #
# to deal in the Software without restriction, including without limitation   #
# the rights to use, copy, modify, merge, publish, distribute, sublicense,    #
# and/or sell copies of the Software, and to permit persons to whom the       #
# Software is furnished to do so, subject to the following conditions:        #
#                                                                             #
# The above copyright notice and this permission notice shall be included in  #
# all copies or substantial portions of the Software.                         #
#                                                                             #
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR  #
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,    #
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE #
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER      #
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING     #
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER         #
# DEALINGS IN THE SOFTWARE.                                                   #
# =========================================================================== #

# The vagrant server is a could-init version of Ubuntu and has not all
# requirements installed. Also because of the eol of python 2.7.x we are going
# to use python3 from this point on.
echo "[Waiting]: Updating Ubuntu apt repository's."
if (sudo apt-get update &> /dev/null); then
    echo "[Success]: Ubuntu apt repository's are updated."
else
    echo "[Failure]: Could not update Ubuntu apt repository's."
    exit 1
fi

echo "[Waiting]: Installing pip3 requirement."
if (sudo apt-get install --yes python3-pip &> /dev/null); then
    echo "[Success]: Pip3 requirement is installed."
else
    echo "[Failure]: Could not install pip3 requirement."
    exit 1
fi

# After the installation of python3-pip requirement we can update pip and
# install Ansible by using pip. This will ensure Ansible is using python3
echo "[Waiting]: Updating pip to latest version."
if (sudo -H pip3 install pip --upgrade &> /dev/null); then
    echo "[Success]: pip is upgraded to latest version."
else
    echo "[Failure]: Could bot upgrade pip to latest version."
    exit 1
fi

# Deploy public and private keypair for ssh connection between servers
echo "[Waiting]: Deploy ssh keypair."
if [ ! -f "id_rsa.pub" ]; then
    echo "[Failure]: Could not find ssh keypair."
    exit 1
else
    cat id_rsa.pub >> .ssh/authorized_keys
    rm id_rsa.pub
fi
echo "[Success]: Ssh keypair is deployed."

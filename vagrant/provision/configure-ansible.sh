#!/usr/bin/env bash

# =========================================================================== #
# File     : configure-ansible.sh                                             #
# Purpose  : Provision script for vagrant ansible server                      #
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

# Check of user that runs this script is not root
#if [ "${UID}" -eq 0 ]; then
#    echo "[Failure]: This script can't be runned with root privileges."
#    exit 1
#fi

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

echo "[Waiting]: Installing latest version of Ansible."
if (sudo -H pip install ansible &> /dev/null); then
    echo "[Success]: Latest version of Ansible is installed."
else
    echo "[Failure]: Could not install the latest version of Ansible."
    exit 1
fi

# Because we use the most basic version of vagrant without any plugins we
# need to add all hosts to the hosts file on the ansible server. If you use
# hostnames that are in a DNS, this step is not required.
echo "[Waiting]: Configurating hosts file to work with Ansible."
sudo cat << EOF >> /etc/hosts
172.16.20.200   ansible.example.com     ansible
172.16.20.201   server01.example.com    server01
172.16.20.202   server02.example.com    server02
EOF
echo "[Success]: Hosts file is configurated."

# Because this is a development / demo environment we are going to disable
# strict hostkey checking in the users .ssh/config file.
echo "[Waiting]: Configurating local users ssh config."
cat << EOF > .ssh/config
Host 172.16.2*.* *.example.com
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
EOF
chown vagrant:vagrant .ssh/config
echo "[Success]: Local user ssh configuration configured."

# For speedup purposes a default ansible skeleton will be deployed from a tarball
echo "[Waiting]: Creating ansible skelton directory."
if [ ! -f "ansible.tar.gz" ]; then
    echo "[Failure]: Could not find ansible.tar.gz."
    exit 1
else
    tar zxvf ansible.tar.gz &> /dev/null
    rm -f ansible.tar.gz &> /dev/null
fi
echo "[Success]: Skeleton Ansible directory is created."

# Deploy public and private keypair for ssh connection between servers
echo "[Waiting]: Deploy ssh keypair."
if [ ! -f "id_rsa" ] || [ ! -f "id_rsa.pub" ]; then
    echo "[Failure]: Could not find ssh keypair."
    exit 1
else
    mv id_rsa .ssh/id_rsa
    chmod 0400 .ssh/id_rsa
    cat id_rsa.pub >> .ssh/authorized_keys
    mv id_rsa.pub .ssh/id_rsa.pub
fi
echo "[Success]: Ssh keypair is deployed."

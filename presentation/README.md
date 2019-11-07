# Presentation

This paer contains the Ansible presentation

## requirements

    - docker

## Installation

```bash
vagrant ssh ansible.example.com
sudo apt-get update
sudo apt-get remove docker docker-engine docker.io
sudo apt-get install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add –
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu  $(lsb_release -cs)  stable"
sudo apt-get update
sudo apt-get install docker-ce
sudo usermod -aG docker vagrant

# copy Makefile and slides.md to a directory
make run    # starts presentation on http://172.16.20.200:8000
make stop   # stps presentation
```

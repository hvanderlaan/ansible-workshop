# Vagrant

This will create a demo environment

## How to use

    1. download this repository
    2. open terminal/powershell or command prompt
    3. unzip repository
    4. cd into vagrant directory

```bash
vagrant up
vagrant ssh ansible.example.com

# in vagrant server ansible.example.com
cd ansible
ansible all -m ping
ansible all -m ping -b

# to stop vagrant servers
vagrant halt

# to remove vagrant servers
vagrant destroy
```

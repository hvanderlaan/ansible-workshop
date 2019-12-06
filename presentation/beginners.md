![Ansible](https://getvectorlogo.com/wp-content/uploads/2019/01/red-hat-ansible-vector-logo.png)<!-- .element height="100%" width="100%"style="border: 0; background: None; box-shadow: None" -->

Welkom.

---
## About me

![Harald van der Laan](https://www.haraldvdl.nl/img/avatar-harald.jpg) <!-- .element height="30%" width="30%"style="border: 0; background: None; box-shadow: None" align="left" -->

Harald van der Laan, Senior Opensoyrce consultant @ AnylinQ. With +15 years of IT experiance. In my spare time I'm testing IOT security, and creating API for them.

---
## Workshop content

- Introduction to Ansible
- Basic concepts
- Ansible inventory
- Ansible and variables
- Ansible Roles

---
## Introduction to Ansible

- What is Ansible
- Why use Ansible

--
## What is Ansible

Ansible is a **configuration** and **deployment** tool to create servers ot application repeatably to a desired state.

--
## Why use Ansible

Ansible is an easy to install, easy to learn configuration and deployment tool. With a minimal set of requirements, and uses no agent.

- ssh on host and target
- python on host

If you have ssh permissions Ansible will work for you with your owb username and password. If you have sudo permissions Ansible can do administrative operations.

---
## Getting start with Ansible

- Installation of Ansible
- First steps with Ansible
- ssh-keys
- Demo

--
## Installation of Ansible

The installation of Ansible is straight forward. In most cases you can you the default packetmanager (apt, yum, ...).

If you need the latest version you can use python's packetmanager pip

```bash
pip ubstall --upgrade ansible
```

--
## First steps with Ansible

Ansible can be used with playbooks but you can run Ansible also in an **AdHoc** mode. For example if you  need to run one command on multiple targets. 

You can even use all default modules that are shipped with Ansible.

--
## First steps with Ansible

```bash
# Display hostname
ansible localhost -a "hostname"

# AdHoc update of debian system
ansible localhost -a "apt-get --yes upgrade" -b
ansible localhost -m apt -a "upgrade=safe" -b

# Getting al; facts of target
ansible localhost -m setup
```

--
## Ssh / ssj-keys

Ansible uses ssh to connect to a target, thrtrfor you need login credentials. The best way to do this is wuth ssh-keys and a service account for Ansible. This way you don't need passwords. Although you can use usersnames and password with ansible.

```bash
# example oof password usage
ansible example.com -m setup -K -b
```

```bash
# creating a ssh-key
ssh-keygen -f ~/.ssh/ansible
```

--
## Demo

The following demo will show the installation of Ansible and configuration of ssh-key. 

---
## Basic concepts

- Inventory
- Modules
- Playbooks
- Tasks
- Templates
- Handlers
- Variales
- Roles

---
## Inventory

The Ansible inventory is one of the most important files of Ansible. The inventory is list of servers or groups that can be managed with Ansible. The inventory cou;d be a static file of a script that create's a dynamic inventory.

If a target is not in the inventory Ansible will not connect to that target.

--
## Inventory: Static example

```ini
[webservers]
web01.example.com ansible_host=10.0.0.101
web02.example.com ansible_host=10.0.0.102
web03.example.com ansible_host=10.0.0.103
web04.example.com ansible_host=10.0.0.104

[dbservers]
bd01.example.com ansible_host=10.0.0.201
bd02.example.com ansible_host=10.0.0.202
bd03.example.com ansible_host=10.0.0.203
bd04.example.com ansible_host=10.0.0.204

[application:children]
webservers
dbservers
```

---
## Ansible Configration

```ini
[defaults]
hostfile = ./inventory
roles_path = ./roles
library = ./library
filter_plugins = ./plugins/filter
lookup_plugins = ./plugins/lookup
callback_whitelist = profile_tasks,timer

[ssh_connection]
pipelining = True
control_path = %(directory)s/ssh-%%h-%%p-%%r
```

--
## Configuration explanation

- hostfile = ./inventory allows inventory to be stored next to the playbooks it is for
- library = ./library allows the easy installation of custom modules near the code (useful if a module is not available from Ansible or a bug has been fixed for a newer/unreleased version)
- filter_plugins = ./plugins/filter — allows for addition of new plugins for Jinja templating
- callback_whitelist = profile_tasks, timer turns on timing information for individual tasks and for the playbook run as a whole

--
## Configuration explanation
- pipelining = True speeds up the execution of modules as ansible only has to run one ssh command, not three.
- control_path reduces the length of the default setting, which is useful if you have long hostnames (as the setting can only be 106 characters)

---
## Modules

Modules are designed to provide an abstraction around simple and complex tasks to allow them to be repeatable and handle error conditions nicely.

--
## Build-in modules

- Configuring service in VMWare, AWS, Azure, etc ..
- Installing and updating packages
- Creating, modifing and deleting files
- Updating network devices
- Configuring databases
- And many more ...

See the [Ansible modules index](https://docs.ansible.com/ansible/latest/modules/modules_by_category.html) for the full list.

--
## Mudoles demo

Using the ansible command line utility, it's easy to run a simple module to get all of the facts from a repo

```bash
ansible localhost -m setup
absuvle localhost -m ping
ansible localhost -m command -a "apache2ctl restart" -b
ansible localhost -m service -a "name=apache2 state=restarted" -b
```

The default module Absible will use is the command module. In the example above of restarting apache could be shorter.

```bash
ansible localhost -a "apache2ctl restart:
```

--
## Ansible-doc

ansible-doc is very useful for finding the syntax of a module without having to look it up online

```bash
ansible-doc <module name>
ansible-doc mysql-user
ansible-doc lineinfile
```

---
## Playbooks

 playbook is, at its simplest, a list of tasks to run in sequence against a list of hosts. The setup task is run first.

 ```ini
 ---
 - hosts: target
   become: true
   
   tasks:
     - name: Ensure ~/.remove does not exists
       file:
         path: ~/.remove
         state; absent
```

---
# Tasks

A task comprises the module to run and the arguments with which to run the task.

There are also several modifiers to the task, determining whether it is run, who it is run by, where it is run, and others.

--
## Naming tasks

Best practices suggest always naming tasks — it's easier to follow what is happening if the tasks are well named.

Naming tasks also allows the use of `--start-at-task` to allow ansible-playbook to start at a later point in the playbook

--
## Naming tasks

The task in the previous playbook looks like this when named:

```bash
TASK [ensure ~/.remove does not exist] ****************************************
ok: [target]
```

And when not named:

```bash
TASK [file] ********************************************************************
ok: [target]
```

---
## Task modifiers

Tasks modifiers are conditions, these conditions will determin if a tasks should run. Or if a task should loop. But can also be used for running a tasks wirh administrative permissions.

--
## Task modifiers: when

The modifier when will ensure a task to run or no not to run when the condition is True or False.

```ini
- name: RedHat -> install httpd
  yum:
    name: https
    state: present
  when: 'ansible_distribution == "RedHat"'

- name: Debiam -> install apache2
  apt:
    bane: apache2
    state: present
  when: 'ansible_distribution == "Debian"'
```

--
## Task modifiers: with_items / loop

A task can loop over a list of items (or indeed many other kinds of data structures). For example, you can provide a list of packages for apt or yum to install, or a list of definitions of database users (username, password, privileges etc).

```ini
- name: create mysql users
  mysql_user:
    name: "{{ item.name }}"
    password: "{{ item.password }}"
  loop:
    - name: bob
      password: foobar
    - name: admin
      oassword: Sup3Rs3Cur3!
```

--
## Task modifiers: become

The become modifiers are useful when you need a task to run as a different user to the rest of the playbook. Security best practices suggest using a standard user for most tasks and elevating privilege when required — but even if you're running the playbook as root, you might need to become e.g. the postgres user to run a DB related task.

--
## Task modifiers: Become example

```ini
- name: install package
  yum:
    name: httpd
    state: present
  become: yes

- name: connect to the database
  command: psql -U postgres 'select * from pg_stat_activity()'
  become_user: postgres
  ```

---
## Best practices: playbook

There are a number of elements to a playbook, that can be separated into the following classes of elements:

- Connection specification: hosts, forks, serial
- User specification: remote_user, become, become_user etc.
- Variable inclusion: vars, vars_files, vars_prompt etc.
- Logic before tasks: pre_tasks, roles
- Tasks and handlers: tasks, handlers

--
## Best practices: playbook

Playbooks can also include other playbooks, using include at the play level, or include task files by using the include task

```ini
- hosts: all

  include: another_playbook.yml

  tasks:
  - include: setup.yml
  - include: configure.yml
```

--
## Best practices:: check mode

Ansible can be run in test mode using the `-C` or `--check-mode` flags.

```bash
ansible-playbook -C examples/playbook.yml
```

Because ansible doesn't know if a command will have an effect in dry run mode, tasks that don't support dry run (particularly command and shell tasks) are skipped by default. You can force them to be run using the check_mode flag (previously the always_run flag)

--
## Check mode example

```ini
- name: get version of coreutils rpm
  command: rpm -q coreutils
  args:
    warn: no
  changed_when: False
  check_mode: yes
```

You can also do things differently when in check mode by changing behaviour based upon `when: ansible_check_mode.`

--
## Diff Mode

Diff mode is incredibly useful in conjunction with check mode to see how a file would change, before the change is made. Diff mode can be run by passing `-D` or `--diff-mode` to ansible-playbook

--
## Repeatability

If a playbook runs twice, the expected result is that nothing should change on the second run — ansible should report zero changes.

This should be true whether 10 seconds later, or 10 months later.

--
## Repeatability

In particular, shell and command will always return changed: True. Use of `changed_when: False` when running read-only commands is encouraged to minimise false alarms:

```ini
- name: get list of files in a directory
  command: ls /path/to/directory
  register: directory_contents
  changed_when: false
  check_mode: true
```

--
## Command tasks

Other means of reducing the amount of unnecessary changes:
- use creates or removes with commands to prevent an action happening if it's already happened
- use when with a pre-check read-only task (with changed_when: False) to see if an action needs to happen before doing it

--
## Command pre-check example

```ini
- name: check tuned profile
  command: tuned-adm active
  register: tuned_adm
  changed_when: False

- name: set tuned profile
  command: tuned-adm profile virtual-guest
  when: "'Current active profile: virtual-guest' \
         not in tuned-adm.stdout"
```

--
## Best practice: Debug messages

You can (and should) configure your debug messages to appear only at certain verbosities

```ini
debug:
  message: "This will appear with -vv but not before"
  verbisity:2
```

--
## Playbook directory structure

For any self-contained set of playbooks (this might be all of your playbooks, or playbooks just for a particular application), the following is a reasonable directory structure

```ini
.
├── ansible.cfg
├── inventory
│   └── group_vars
│       └── web
└── playbooks
    ├── simple
    │   ├── deploy-web-service.yml
    │   └── templates
    │       ├── index.html.j2
    │       └── python-web.service.j2
    └── with_roles
```

---
## Templates

- Templates allow you to generate configuration files from values set in various inventory properties. This means that you can store one template in source control that applies to many different environments.

- Ansible uses the Jinja templating language. The language offers control structures `({% for %}`, `{% if %}` etc.) and filters that process variables (e.g. `{{ "hello"|upper }} would print HELLO`.

--
## Template example

An example might be a file specifying database connection information that would have the same structure but different values for dev, test and prod environments

```ini
$db_host = '{{ database_host }}';
$db_name = '{{ database_name }}';
$db_user = '{{ database_username }}';
$db_pass = '{{ database_password }}';
$db_port = {{ database_port}};
```

--
## Using templates

Templates are populated by using the template module

```ini
- name: Apache2 -> deploy configuration
  template:
    src: 00-default.conf.j2
    dest: /etc/apache2/site-enabled/00-default.conf
```

--
## Template directory structure

Because configuration files for an application can end up with similar names in different directories, reflect the target destination in the source repository

```ini
- name: configure logrotate
  template:
    src: etc/logrotate.d/httpd.conf.j2
    dest: /etc/logrotate.d/httpd.conf

- name: configure apache
  template:
    src: etc/httpd/conf/httpd.conf.j2
    dest: /etc/httpd/conf/httpd.conf
    owner: apache
```

---
## Handlers

Handlers are tasks that are 'fired' when a task makes a change

```ini
tasks:
  - name: install httpd configuration file
      template:
        src: etc/httpd/conf/httpd.conf.j2
        dest: /etc/httpd/conf/httpd.conf
      notify: reload apache

handlers:
  - name: reload apache
      service:
        name: apache
        state: reloaded
```

--
## Handlers

This is another mechanism of ensuring a change is made only when it needs to be (as if no change is made to the configuration, the handler will not fire)

Handlers are run at the end of all tasks — if you want to run them earlier, you can use the meta task:

```ini
- meta: flush_handlers
```

---
## Variables

- In general logic should be the same (or similar) for all environments.
- Variables fill in the contents of template files, can be used for the source of files, and to choose whether or not to perform a task (to name some reasons)
- Fewer variations in configuration sources reduces likelihood of errors (Don't Repeat Yourself)

---
## Variables in the inventory

- Inventory is used to define the hierarchy of hosts and the groups to which they belong.
- The inventory source can be a file, or a script, or a directory containing such files and scripts.
- Ansible also sources host variables and group variables from host_vars and group_vars stored in the inventory directory

--
## Inventory inheritance

- Inventory variables take precedence the closer they are to the host.
- Host variables override group variables
- Child group variables override their parents
- This means you can set defaults in top level groups, and override them lower down (e.g. the default log level for an application might be WARN, but in development it should be DEBUG).

--
## Best practices: Inventory

- Set hosts_file in the ansible configuration file to a directory
- Each file in that directory can be an independent part of the inventory
- Inventory scripts can also live in that directory
- That directory can contain host_vars and group_vars

--
## Anti-pattern: variables in host files

- Variables should not be stored in inventory host files (using [group:vars] or [host:vars] mechanism) — the inventory files should be used for group contents and hierarchy definitions (using [group:children]).
- Use group_vars instead, or host_vars at a push.

---
## Best practices: host_vars

Host variables should be used only for things that will only be true for a single host. An example of this might be caching of a UUID of a host, or setting kerberos keytabs

This means that SSL certificates and keys, kerberos keytabs, server uuids etc. might be candidates, but most other inventory variables will be properties of groups.

---
## Playbook vars and vars_prompt

In general playbooks shouldn't need to define vars, but the capability exists.

vars_prompt is useful if you need to provide a variable at run time — e.g. a password for a service and don't want to source it from a vaulted file.

--
## var_prompt example

```ini
- hosts: certificate_authority

  vars_prompt:
  - name: ca_password
    prompt: "Please enter your CA password"

  tasks:
  - name: sign certificate
    command: openssl ca -in req.pem \
      -out newcert.pem -passin env:CA_PASSWD
    environment:
      CA_PASSWD: "{{ ca_password }}"
```

--
## Registered variables

registered variables used to store the results of a task in a playbook.

```ini
- name: get stat data for file
  stat:
    path: /path/to/file
  register: stat_file

- name: fail if path doesn't exist
  fail:
    msg: "File does not exist"
  when: not stat_file.stat.exists
```

--
## Facts

- Information about a host sourced at runtime, e.g. IP address or OS version.
- You don't need to run the setup module directly to gather facts — it is always run in playbook mode, unless gather_facts is set to False

--
## set_fact module

The set_fact module is used to derive new facts from existing facts to produce more useful ones.

```ini
- name: set timezone fact
  set_fact:
  args:
    timezone: "{{ ansible_date_time.tz }}"
```

--
## det_fact examples

If os_version is the fact obtained by joining ansible_distribution with ansible_distribution_major_version then:

- The following will look under the vars directory of a role for a file called e.g. CentOS7.yml

```ini
 name: include variables based on OS version
    include_vars: "{{ os_version }}.yml"
```

--
## include_var / vars_files

- Use include_vars to include a variables file as a task in a playbook run. You can use no_log to ensure vars aren't logged.
- You can also use vars_files in a playbook to include one or more variables files. vars_files can't be used in a role.

--
## Wxtra vars -e

- Command line extra vars are useful for setting configuration at run-time.
- Set lots of variables at once by including a variables file using -e @filename.yml — can be useful for overriding defaults during an outage.

--
## Variable precedence

The order of variables presented has been in increasing order. There are more variable types than presented here — others aren't widely used or highly recommended

---
## Secret Variables

ansible provides a tool called ansible-vault for encrypting secret variables. while other tools are available, the vault is usefully integrated.

--
## ansible-vault

- create: `ansible-vault create secrets.yml`
- edit: `ansible-vault edit secrets.yml`
- view: `ansible-vault view secrets.yml`
- encrypt existing file: `ansible-vault encrypt secrets.yml`
- decrypt existing file: `ansible-vault encrypt secrets.yml`
- change password: `ansible-vault rekey secrets.yml`

--
## Using vaulted secrets

```bash
ansible=playbook playbook.yaml --ask-vault-pass
ansible-playbook playbook.yaml --vault-password-file=~/ansible.pass
```

---
## Roles: What is a role

- Roles are reusable packages of configuration included by playbooks
- Roles can do most of the things that playbooks do — run tasks and handlers, install files or write templates, set variables
- Examples include roles that install database engines (mysql, postgresql etc.), web servers (apache, nginx) and many more

--
## Why do we have roles

- Roles should implement best practices (e.g. an apache role that enforced secure SSL ciphers)
- If more than one playbook might do something in the same way, that should be abstracted to a role

--
## Where do roles come from

- [Ansible Galaxy](http://galaxy.ansible.com/) (https://galaxy.ansible.com) — there are 1000s of roles suitable for most operating systems
- ansible-galaxy init new-role creates a role skeleton

--
## Ansible role skeleton

```ini
testrole/
├── defaults         ├── tasks
│   └── main.yml     │   └── main.yml
├── files            ├── templates
├── handlers         ├── tests
│   └── main.yml     │   ├── inventory
├── meta             │   └── test.yml
│   └── main.yml     └── vars
└── README.md            └── main.yml
```

--
## Installing a role

Best practice is to use a requirements.yml file containing the specification of the role you wish to use. This can be from Ansible Galaxy or from github or your own internal source repository.

--
## requirements.yaml

The following are effectively equivalent:

```ini
- src: geerlingguy.mysql

- src: https://github.com/geerlingguy/ansible-role-mysql
  version: 2.4.0
  name: mysql
  scm: git
```

The latter mechanism is more useful for roles that don't come from galaxy.

--
## Installing the role

The roles are then installed using

```bash
ansible-galaxy install -p playbooks/application/env/roles \
  -r playbooks/application/env/requirements.yml -f
  ```

--
## Using the role

- Read the README file to see what variables are expected, and then set them appropriately in inventory.
- Rather than a bunch of tasks, your playbook might then look like

```ini
  - hosts: appserver

    roles:
    - mysql
    - nginx
    - application
```

where application might be your role that installs your own application

--
## Creating new roles

- The ansible-galaxy init rolename (http://docs.ansible.com/galaxy.html) command can be use to create new roles
- Each application-environment combination gets its own roles file used to provide roles for the playbooks

---
## Tools

There are a lot of tools that can help you with creating playbooks, roles and even modules. in this section there are some usefull tools

---
## Syntax: ansible

For syntax checking you can use the ansible application, this will preform a drytun that will check your playbook and roles on syntax errors.

```bash
ansible-playbook playbooks.yaml --syntax-check
```

--
## Syntax: ansible-lint

ansible-lint was developed to find various style and usage issues with playbooks and roles, and suggest improvements.

There are several categories of rules:

- Using command/shell module instead of Ansible modules
- Deprecated syntax that is being removed by Ansible
- Incorrect formatting

--
## Syntax: ansible-lint

Every rule is treated as an error — there is no way to mark rules as warnings. You can choose to run specific rules or to exclude specific rules

---
## Suntax highlight: vscode / atom

It is a best practuce to use syntax highlighting in your editor. vs code and Atom have a good YAML highlighter, but it is better to download an Ansible syntax highlighter. There are also highlighters for vi if that is you preffered editor.

---
## Version control

For all plaubooks, roles and modules it is best practice to place the code in some sort of version control. This could be svn, git, bitbucket, etc... This makes tracking of updates easier.

---
## Development

For developing playbooks, roles or modules. It is best to do this in a development environment. Such an environment could be created with:

- vagrant
- virtualbox
- docker

---
## Task: users

Create a playbook that creates a new user on all servers. The user should be ansible, with a home directory on /home/ansible. This user should have sudo permissions with no password. And you can use the vagrant ssh-key to logon to this user. 

Modules to use: user, file, lineinfile, authorized_key

sudo line: ansible  ALL = (ALL) NOPASSWD: ALL
--
## Task: users role

create a role that doest exactly the same as the previous playbook

---
# Question ??

---
## Thanks

- Feedback is welcome: harald.van.der.laan@anylinq.com
- Fork Me: https://github.com/hvanderlaan/ansible-workshop

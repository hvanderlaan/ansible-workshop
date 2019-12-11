![Ansible](https://getvectorlogo.com/wp-content/uploads/2019/01/red-hat-ansible-vector-logo.png)<!-- .element height="100%" width="100%"style="border: 0; background: None; box-shadow: None" -->

Welkom.

---
## About me

![Harald van der Laan](https://www.haraldvdl.nl/img/avatar-harald.jpg) <!-- .element height="30%" width="30%"style="border: 0; background: None; box-shadow: None" align="left" -->

Harald van der Laan, Senior Opensoyrce consultant @ AnylinQ. With +15 years of IT experiance. In my spare time I'm testing IOT security, and creating API for them.

---
## Workshop content
- Best practice
- Roles
- Conditions
- Handlers
- Templates
- User creation
- Vault
- Roling upgrades
- Debugging
- Error handleing

---
## Best practices

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
## Roles

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
## Example of a role

--
## Exercise: Create a role

Create a role that will install apache . Apache must start when the server is restarted. You don't need to configure apache.
---
## Conditions / Modifiers

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

--
## Example: Handlers

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
## Exercise: Handlers

Create a role or playbook that changes the sshd configuration and when the configuration is changed, sshd must be restarted.

Modules to use `lineinfile` and change the setting `PermitRootLogin` to no

---
## Templates
- Templates allow you to generate configuration files from values set in various inventory properties. This means that you can store one template in source control that applies to many different environments.

- Ansible uses the Jinja templating language. The language offers control structures `({% for %}`, `{% if %}` etc.) and filters that process variables (e.g. `{{ "hello"|upper }} would print HELLO`.

--
## Template example

An example might be a file specifying database connection information that would have the same structure but different values for dev, test and prod environments

```ini
########################################################
## WARNING: This server is managed with Ansible       ##
##          Please make changed to the Ansible soyrce ##
##          and not on the server                     ##
########################################################

os  : {{ansible_system}} - {{ ansible_lsb.description }}
type: {{ ansible_virtualization_role }}
fqdn: {{ ansible_fqdn }}
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
--
## Exercise: Templates

Creatd your own dynamic motd template and make use of Ansible variables.

---
## User creation

Fir creating users you can use the user module of Ansible. With this module it is possible to create new users with passwords, home directory's, set shells or add to groups.

--
## Example: User playbook

--
## Exercise: Users

Create a playbook that will add a user to the servers, with a password and sshkeu.

---
## Vault

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

--
## Exercise: Vault

Create your own secure inventory or variables file with ansible-vault. Test this with a playbook.
Use the edit function to edit an ansible-vault file.

---
## Roling upgrades

With rolling upgrades you can update applications or servers in batches. When one or more fails Ansible stop and the other applications or servers will not update. This will ensure when something fails a set of working applications or servers are still live.

--
## VMWare

Ansible can communicate witj the API of VMWare. With the module `vmware_guest_snapshot` it is possible to create a snapshot before the update. If an update fauils Ansible could revert to the snapshot. This would require a `block` and `rescue` section in your playbook,

--
## VMware

```ini
- name: vmware -> find folder by name
  vmware_guest_find:
    hostname: "{{ vcenter_hostname }}"
    username: "{{ vcenter_username }}"
    password: "{{ vcenter_password }}"
    validate_certs: no
    name: "{{ ansible_host }}"
  register: vm_folder
  delegate_to: localhost
```

--
## VMWARE

```ini
- name: Create VM snapshot
  vmware_guest_snapshot:
    hostname: "{{ vcenter_hostname }}"
    username: "{{ vcenter_username }}"
    password: "{{ vcenter_password }}"
    validate_certs: no
    datacenter: Hengelo
    folder: vm_folder
    name: "{{ ansible_host }}"
    state: present
    snapshot_name: pre-os-updates
  delegate_to: loca;host

```

--
## Serial

To use rolling updates you need to use the `serial` option in your playbook or in de the `ansible.cfg`

```ini
- hosts: all
  become: true
  serial: 4

  ....
```

This will update the application or servers in batches of 4

---
## Debugging / error handleing

By default Ansible is not very clear in error messages. The most common error are:

- YANK Synrax error - Ansible will not run
- Module errors - Ansible will run

--
## YAML Syntax

The best way of debugging Yaml Syntax errors are to use an IDE with syntax highlighting or a linter.

- Atom, VScide, vi
- ansible-lint

`Also it is best to use spaces instead of tabs`

--
## Ansible modules

When you have a module error it is hard to debuf the playbook. Most of the time it is a miss spelled tag of the module. When this happens it is best to consult the Ansible documentation online or use the command: 

ansible-doc [module name]
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

---
## Templates

---
## User creation

---
## Vault

---
## Roling upgrades

---
## Debugging

---
## Error handleing
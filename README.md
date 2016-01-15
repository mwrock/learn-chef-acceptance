# learn-chef-acceptance
Testing framework for Learn Chef tutorials.

Each cookbook models a Learn Chef tutorial through Test Kitchen and Chef audit mode. The process works in two phases.

* **Phase 1**: Use Chef to replay each tutorial step. The `workflow` cookbook provides resources that run commands (the tutorial steps) and cache the result to disk. Think of these as `execute` resources that also pipe the stdout & stderr streams and the exit code to files.
* **Phase 2**: Run audit mode controls to verify that the scenario succeeds and that the output matches the sample output that's shown in the tutorial.

## Catalog

* `learn-the-basics-rhel`: [Learn the Chef basics on Red Hat Enterprise Linux](https://learn.chef.io/learn-the-basics/rhel/)
* `learn-the-basics-windows`: [Learn the Chef basics on Windows Server](https://learn.chef.io/learn-the-basics/windows/)
* `learn-the-basics-ubuntu`: [Learn the Chef basics on Ubuntu](https://learn.chef.io/learn-the-basics/ubuntu/)

## Usage

Just run `kitchen converge` from any cookbook directory for the scenario you want to validate.

## Requirements

Here are the software requirements for each tutorial's validation cookbook.

### learn-the-basics-rhel

* Vagrant
* VirtualBox

### learn-the-basics-windows

* Vagrant
* VirtualBox

### learn-the-basics-ubuntu

* Vagrant
* VirtualBox

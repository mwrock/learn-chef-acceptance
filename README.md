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

Just run `kitchen converge` from any cookbook directory for the scenario you want to validate. Specific commands shown below.

## Requirements

Here are the software requirements for each tutorial's validation cookbook.

For AWS, you'll need the [Test Kitchen EC2 driver](https://github.com/test-kitchen/kitchen-ec2), which you can install by running `chef gem install kitchen-ec2`.

For AWS, you'll also need to modify the `.kitchen.yml` file to use your region, SSH key, security group, and AMI ID. We plan to make this more general.

### learn-the-basics-rhel

#### Vagrant

* Software:
  * Vagrant
  * VirtualBox
* Run it:
  * `kitchen converge default-centos-65`

#### AWS

* Software:
  * kitchen-ec2
* Run it:
  * `kitchen converge default-centos-65-aws`

### learn-the-basics-windows

#### Vagrant

* Software:
  * Vagrant
  * VirtualBox
* Run it:
  * `kitchen converge default-windows-2012R2`

#### AWS

* Software:
  * kitchen-ec2
* Run it:
  * `kitchen converge default-windows-2012R2-aws`

### learn-the-basics-ubuntu

#### Vagrant

* Software:
  * Vagrant
  * VirtualBox
* Run it:
  * `kitchen converge default-ubuntu-1404`

#### AWS

* Software:
  * kitchen-ec2
* Run it:
  * `kitchen converge default-windows-ubuntu-1404`

#
# Cookbook Name:: learn-the-basics-rhel
# Recipe:: _setup
#
# Copyright (c) 2015 The Authors, All Rights Reserved.
execute 'install Chef DK' do
  command 'curl https://omnitruck.chef.io/install.sh | sudo bash -s -- -c current -P chefdk'
  not_if 'which chef'
end

control_group 'validate Chef DK installation' do
  control 'validate version' do
    describe command('chef --version') do
      its (:stdout) { should match /Chef Development Kit Version: 0.10.0/ }
      its (:stdout) { should match /chef-client version: 12.6.0/ }
    end
  end
end

package 'curl'
package 'tree'

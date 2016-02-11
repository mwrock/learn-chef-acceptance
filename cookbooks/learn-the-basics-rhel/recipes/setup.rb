#
# Cookbook Name:: learn-the-basics-rhel
# Recipe:: setup
#
# Copyright (c) 2015 The Authors, All Rights Reserved.
package 'curl'
package 'tree'

unless node['use_system_chef']
  execute 'install Chef DK' do
    command 'curl https://omnitruck.chef.io/install.sh | bash -s -- -c current -P chefdk'
    not_if 'which chef'
  end

  control_group 'validate Chef DK installation' do
    control 'validate version' do
      describe command('chef --version') do
        its (:stdout) { should match /Chef Development Kit Version: 0.11.0/ }
        its (:stdout) { should match /chef-client version: 12.7.0/ }
      end
    end
  end
end

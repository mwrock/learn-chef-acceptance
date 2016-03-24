#
# Cookbook Name:: learn-the-basics-rhel
# Recipe:: setup
#
# Copyright (c) 2015 The Authors, All Rights Reserved.
package 'curl'
package 'tree'

unless node['use_system_chef']
  execute 'install Chef DK' do
    command "curl https://omnitruck.chef.io/install.sh | sudo bash -s -- -c #{node[:workflow][:packages][:chef_dk][:channel]} -P chefdk"
    not_if 'which chef'
  end

  chefdk_version_matcher = "Chef Development Kit Version: #{node[:workflow][:packages][:chef_dk][:chefdk_version]}"
  chef_client_version_matcher = "chef-client version: #{node[:workflow][:packages][:chef_dk][:chef_client_version]}"

  control_group 'validate Chef DK installation' do
    control 'validate version' do
      describe command('chef --version') do
        its (:stdout) { should match /#{Regexp.quote(chefdk_version_matcher)}/ }
        its (:stdout) { should match /#{Regexp.quote(chef_client_version_matcher)}/ }
      end
    end
  end
end

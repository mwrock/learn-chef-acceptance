#
# Cookbook Name:: learn-the-basics-windows
# Recipe:: setup
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

unless node['use_system_chef']
  powershell_script 'install Chef DK' do
   code <<-EOH.strip_heredoc
     . { iwr -useb https://omnitruck.chef.io/install.ps1 } | iex; install -channel current -project chefdk
   EOH
   not_if 'Get-Command chef'
  end

  # Ensure `chef` is on the system PATH.
  windows_path node['learn_the_basics']['windows']['chef_path'] do
    action :add
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

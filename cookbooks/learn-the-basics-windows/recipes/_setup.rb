#
# Cookbook Name:: learn-the-basics-windows
# Recipe:: _setup
#
# Copyright (c) 2015 The Authors, All Rights Reserved.
powershell_script 'install Chef DK' do
  code <<-EOH
  . { iwr -useb https://omnitruck.chef.io/install.ps1 } | iex; install -channel current -project chefdk
  EOH
  not_if 'Get-Command chef'
end

control_group 'validate Chef DK installation' do
  control 'validate version' do
    describe command('chef --version') do
      its (:stdout) { should match /Chef Development Kit Version: 0.10.0/ }
      its (:stdout) { should match /chef-client version: 12.6.0/ }
    end
  end
end
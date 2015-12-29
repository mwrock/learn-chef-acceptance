#
# Cookbook Name:: .
# Recipe:: _lesson1
#
# Copyright (c) 2015 The Authors, All Rights Reserved.
working_dir = File.join(ENV['HOME'], 'chef-repo')
motd_file = File.join(working_dir, 'motd')

# 1. Set up your working directory
directory working_dir do
  action [:delete, :create]
  recursive true
end

# 2. Create the MOTD file
cookbook_file File.join(working_dir, 'hello.rb') do
  source 'hello_0.rb'
end

execute 'chef-apply hello.rb' do
  command 'chef-apply hello.rb --no-color --force-formatter | tee step_2.out'
  cwd working_dir
end

execute 'cp motd motd.2' do
  command 'cp motd motd.2'
  cwd working_dir
end

control_group 'step 2' do
  control 'validate output' do
    describe file(File.join(working_dir, 'step_2.out')) do
      its(:content) { should match /^Recipe: \(chef-apply cookbook\)::\(chef-apply recipe\)$/ }
      its(:content) { should match /^\s{2}\* file\[motd\] action create$/ }
      its(:content) { should match /^\s{4}- create new file motd$/ }
      its(:content) { should match /^\s{4}- update content in file motd from none to [a-z0-9]*$/ }
      its(:content) { should match /^\s{4}--- motd/ }
      its(:content) { should match /^\s{4}@@ \-1 \+1,2 @@$/ }
      its(:content) { should match /^\s{4}\+hello world$/ }
      its(:content) { should match /^\s{4}- restore selinux security context$/ }
    end
  end
  control 'validate result' do
    describe command("more #{motd_file}.2") do
      its(:stdout) { should match /^hello world$/ }
    end
    describe file("#{motd_file}.2") do
      it { should be_file }
    end
  end
end

# Run the command a second time

execute 'chef-apply hello.rb' do
  command 'chef-apply hello.rb --no-color --force-formatter | tee step_2_1.out'
  cwd working_dir
end

execute 'cp motd motd.2.1' do
  command 'cp motd motd.2.1'
  cwd working_dir
end

control_group 'step 2-1' do
  control 'validate output' do
    describe file(File.join(working_dir, 'step_2_1.out')) do
      its(:content) { should match /^Recipe: \(chef-apply cookbook\)::\(chef-apply recipe\)$/ }
      its(:content) { should match /^\s{2}\* file\[motd\] action create \(up to date\)/ }
    end
  end
  control 'validate result' do
    describe command("more #{motd_file}.2.1") do
      its(:stdout) { should match /^hello world$/ }
    end
    describe file(motd_file) do
      it { should be_file }
    end
  end
end

# 3. Update the MOTD file's contents

cookbook_file File.join(working_dir, 'hello.rb') do
  source 'hello_1.rb'
end

execute 'chef-apply hello.rb' do
  command 'chef-apply hello.rb --no-color --force-formatter | tee step_3.out'
  cwd working_dir
end

execute 'cp motd motd.3' do
  command 'cp motd motd.3'
  cwd working_dir
end

control_group 'step 3' do
  control 'validate output' do
    describe file(File.join(working_dir, 'step_3.out')) do
      its(:content) { should match /\-hello world/ }
      its(:content) { should match /\+hello chef/ }
    end
  end
  control 'validate result' do
    describe command("more #{motd_file}.3") do
      its(:stdout) { should match /^hello chef$/ }
    end
  end
end

# 4. Ensure the MOTD file's contents are not changed by anyone else

execute "echo 'hello robots' > motd" do
  command "echo 'hello robots' > motd"
  cwd working_dir
end

execute 'chef-apply hello.rb' do
  command 'chef-apply hello.rb --no-color --force-formatter | tee step_4.out'
  cwd working_dir
end

execute 'cp motd motd.4' do
  command 'cp motd motd.4'
  cwd working_dir
end

control_group 'step 4' do
  control 'validate output' do
    describe file(File.join(working_dir, 'step_4.out')) do
      its(:content) { should match /\-hello robots/ }
      its(:content) { should match /\+hello chef/ }
    end
  end
  control 'validate result' do
    describe command("more #{motd_file}.4") do
      its(:stdout) { should match /^hello chef$/ }
    end
  end
end

# 5. Delete the MOTD file

cookbook_file File.join(working_dir, 'goodbye.rb') do
  source 'goodbye.rb'
end

execute 'chef-apply goodbye.rb' do
  command 'chef-apply goodbye.rb --no-color --force-formatter | tee step_5.out'
  cwd working_dir
end

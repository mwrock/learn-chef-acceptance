#
# Cookbook Name:: learn-the-basics-rhel
# Recipe:: _lesson1
#
# Copyright (c) 2015 The Authors, All Rights Reserved.
# Configure a resource
working_dir = File.join(ENV['HOME'], 'chef-repo')

motd_file = '/tmp/motd'

output_dir = File.join(ENV['HOME'], cookbook_name, 'configure-a-resource')

writers = Hash[%w(step2 step2_1 step3 step4 step5).map {
  |step|[step, OutputPath.new(File.join(output_dir, step))]
}]

directory output_dir do
  recursive true
end
writers.each_value do |writer|
  directory writer.base_path
end

# 1. Set up your working directory
directory working_dir do
  action [:delete, :create]
  recursive true
end

# 2. Create the MOTD file
cookbook_file File.join(working_dir, 'hello.rb') do
  source 'hello_1.rb'
end

workflow_execute 'chef-client --local-mode hello.rb --no-color --force-formatter' do
  cwd working_dir
  writer writers['step2']
end

step2_motd = File.join(writers['step2'].base_path, 'motd')

workflow_file_glob motd_file do
  action :copy
  dest step2_motd
end

control_group 'lesson1, step2' do
  control 'validate output' do
    describe file(writers['step2'].stdout_path) do
      [
/WARN: No config file found or specified on command line, using command line options\./,
/WARN: No cookbooks directory found at or above current directory\./,
/Starting Chef Client, version 12\.6\.0/,
/resolving cookbooks for run list: \[\]/,
/Synchronizing Cookbooks:/,
/Compiling Cookbooks/,
/WARN: Node .+ has an empty run list/,
/Converging 1 resources/,
/Recipe: @recipe_files::\/home\/root\/hello.rb/,
/\s{2}* file\[\/tmp\/motd\] action create/,
/\s{4}\- create new file \/tmp\/motd/,
/\s{4}\- update content in file \/tmp\/motd from none to .+/,
/\s{4}\-\-\- \/tmp\/motd/,
/\s{4}\+\+\+ \/tmp\/\.motd/,
/\s{4}\+hello world/,
/\s{4}\- restore selinux security context/,
/Running handlers:/,
/Running handlers complete/,
/Chef Client finished, 1\/1 resources updated in \d\d seconds/
      ].each do |matcher|
        its(:content) { should match matcher }
      end
    end
  end
  control 'validate result' do
    describe command("more #{step2_motd}") do
      its(:stdout) { should match /^hello world$/ }
    end
    describe file(step2_motd) do
      it { should be_file }
    end
  end
end

# Run the command a second time
workflow_execute 'chef-client --local-mode hello.rb --no-color --force-formatter' do
  cwd working_dir
  writer writers['step2_1']
end

step2_1_motd = File.join(writers['step2_1'].base_path, 'motd')

workflow_file_glob motd_file do
  action :copy
  dest step2_1_motd
end

control_group 'lesson1, step2_1' do
  control 'validate output' do
    describe file(writers['step2_1'].stdout_path) do
      [
/WARN: No config file found or specified on command line, using command line options/,
/WARN: No cookbooks directory found at or above current directory/,
/Starting Chef Client, version 12\.6\.0/,
/resolving cookbooks for run list: \[\]/,
/Synchronizing Cookbooks:/,
/Compiling Cookbooks.../,
/WARN: Node .+ has an empty run list/,
/Converging 1 resources/,
/Recipe: @recipe_files::\/home\/root\/chef\-repo\/hello.rb/,
/\s{2}* file\[\/tmp\/motd\] action create \(up to date\)/,
/Running handlers:/,
/Running handlers complete/,
/Chef Client finished, 0\/1 resources updated in \d\d seconds/
      ].each do |matcher|
        its(:content) { should match matcher }
      end
    end
  end
  control 'validate result' do
    describe command("more #{step2_1_motd}") do
      its(:stdout) { should match /^hello world$/ }
    end
    describe file(step2_1_motd) do
      it { should be_file }
    end
  end
end

# 3. Update the MOTD file's contents
cookbook_file File.join(working_dir, 'hello.rb') do
  source 'hello_3.rb'
end

workflow_execute 'chef-client --local-mode hello.rb --no-color --force-formatter' do
  cwd working_dir
  writer writers['step3']
end

step3_motd = File.join(writers['step3'].base_path, 'motd')

workflow_file_glob motd_file do
  action :copy
  dest step3_motd
end

control_group 'lesson1, step3' do
  control 'validate output' do
    describe file(writers['step3'].stdout_path) do
      its(:content) { should match /\-hello world/ }
      its(:content) { should match /\+hello chef/ }
    end
  end
  control 'validate result' do
    describe command("more #{step3_motd}") do
      its(:stdout) { should match /^hello chef$/ }
    end
  end
end

# 4. Ensure the MOTD file's contents are not changed by anyone else
execute "echo 'hello robots' > motd" do
  cwd working_dir
end

workflow_execute 'chef-client --local-mode hello.rb --no-color --force-formatter' do
  cwd working_dir
  writer writers['step4']
end

step4_motd = File.join(writers['step4'].base_path, 'motd')

workflow_file_glob motd_file do
  action :copy
  dest step4_motd
end

control_group 'lesson1, step4' do
  control 'validate output' do
    describe file(writers['step4'].stdout_path) do
      its(:content) { should match /\-hello robots/ }
      its(:content) { should match /\+hello chef/ }
    end
  end
  control 'validate result' do
    describe command("more #{step4_motd}") do
      its(:stdout) { should match /^hello chef$/ }
    end
  end
end

# 5. Delete the MOTD file
cookbook_file File.join(working_dir, 'goodbye.rb') do
  source 'goodbye.rb'
end

workflow_execute 'chef-client --local-mode goodbye.rb --no-color --force-formatter' do
  cwd working_dir
  writer writers['step5']
end

control_group 'lesson1, step5' do
  control 'validate output' do
    describe file(writers['step5'].stdout_path) do
      its(:content) { should match /\s{2}\* file\[\/tmp\/motd\] action delete/ }
      its(:content) { should match /\s{4}\- delete file \/tmp\/motd/ }
    end
  end
  control 'validate result' do
    describe command("more #{motd_file}") do
      its(:stderr) { should match /\/tmp\/motd: No such file or directory$/ }
    end
  end
end

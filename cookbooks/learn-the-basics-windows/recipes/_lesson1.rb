#
# Cookbook Name:: learn-the-basics-windows
# Recipe:: _lesson1
#
# Copyright (c) 2015 The Authors, All Rights Reserved.
# Configure a resource
working_dir = 'C:/Users/Administrator/chef-repo'

settings_ini = File.join(working_dir, 'settings.ini')

output_dir = 'C:/Users/Administrator/configure-a-resource'

writers = Hash[%w(step3 step3_1 step4 step5 step6).map {
  |step|[step, OutputPath.new(File.join(output_dir, step))]
}]

directory output_dir do
  recursive true
end
writers.each_value do |writer|
  directory writer.base_path
end

# 1. Ensure you have Administrator privileges

# 2. Set up your working directory
directory working_dir do
  action [:create]
  recursive true
end

# 3. Create the INI file
cookbook_file File.join(working_dir, 'hello.rb') do
  source 'hello_3.rb'
end

workflow_execute 'chef-apply hello.rb --no-color --force-formatter' do
  cwd working_dir
  writer writers['step3']
end

step3_settings = File.join(writers['step3'].base_path, 'settings.ini')

workflow_file_glob File.join(working_dir, 'settings.ini') do
  action :copy
  dest step3_settings
end

control_group 'lesson1, step3' do
  control 'validate output' do
    describe file(writers['step3'].stdout_path) do
      its(:content) { should match /^Recipe: \(chef-apply cookbook\)::\(chef-apply recipe\)$/ }
      its(:content) { should match /^\s{2}\* file\[C:\\Users\\Administrator\\chef\-repo\\settings\.ini\] action create$/ }
      its(:content) { should match /^\s{4}- create new file C:\\Users\\Administrator\\chef\-repo\\settings\.ini/ }
      its(:content) { should match /^\s{4}- update content in file C:\\Users\\Administrator\\chef\-repo\\settings\.ini/ }
      its(:content) { should match /^\s{4}@@ \-1 \+1,2 @@$/ }
      its(:content) { should match /^\s{4}\+greeting=hello world$/ }
    end
  end
  control 'validate result' do
    describe command("Get-Content #{step3_settings}") do
      its(:stdout) { should match /^greeting=hello world$/ }
    end
    describe file(step3_settings) do
      it { should be_file }
    end
  end
end

# Run the command a second time
workflow_execute 'chef-apply hello.rb --no-color --force-formatter' do
  cwd working_dir
  writer writers['step3_1']
end

step3_1_settings = File.join(writers['step3_1'].base_path, 'settings.ini')

workflow_file_glob File.join(working_dir, 'settings.ini') do
  action :copy
  dest step3_1_settings
end

control_group 'lesson1, step3_1' do
  control 'validate output' do
    describe file(writers['step3_1'].stdout_path) do
      its(:content) { should match /^Recipe: \(chef-apply cookbook\)::\(chef-apply recipe\)$/ }
      its(:content) { should match /^\s{2}\* file\[C:\\Users\\Administrator\\chef\-repo\\settings\.ini\] action create \(up to date\)/ }
    end
  end
  control 'validate result' do
    describe command("more #{step3_1_settings}") do
      its(:stdout) { should match /^greeting=hello world$/ }
    end
    describe file(step3_1_settings) do
      it { should be_file }
    end
  end
end

# 4. Update the INI file's contents
cookbook_file File.join(working_dir, 'hello.rb') do
  source 'hello_4.rb'
end

workflow_execute 'chef-apply hello.rb --no-color --force-formatter' do
  cwd working_dir
  writer writers['step4']
end

step4_settings = File.join(writers['step4'].base_path, 'settings.ini')

workflow_file_glob File.join(working_dir, 'settings.ini') do
  action :copy
  dest step4_settings
end

control_group 'lesson1, step4' do
  control 'validate output' do
    describe file(writers['step4'].stdout_path) do
      its(:content) { should match /\-greeting=hello world/ }
      its(:content) { should match /\+greeting=hello chef/ }
    end
  end
  control 'validate result' do
    describe command("more #{step4_settings}") do
      its(:stdout) { should match /^greeting=hello chef$/ }
    end
  end
end

# 5. Ensure the INI file's contents are not changed by anyone else
powershell_script "Set-Content settings.ini 'greeting=hello robots'" do
  code "Set-Content settings.ini 'greeting=hello robots'"
  cwd working_dir
end

workflow_execute 'chef-apply hello.rb --no-color --force-formatter' do
  cwd working_dir
  writer writers['step5']
end

step5_settings = File.join(writers['step5'].base_path, 'settings.ini')

workflow_file_glob File.join(working_dir, 'settings.ini') do
  action :copy
  dest step5_settings
end

control_group 'lesson1, step5' do
  control 'validate output' do
    describe file(writers['step5'].stdout_path) do
      its(:content) { should match /\-greeting=hello robots/ }
      its(:content) { should match /\+greeting=hello chef/ }
    end
  end
  control 'validate result' do
    describe command("more #{step5_settings}") do
      its(:stdout) { should match /^greeting=hello chef$/ }
    end
  end
end

# 6. Delete the INI file
cookbook_file File.join(working_dir, 'goodbye.rb') do
  source 'goodbye.rb'
end

workflow_execute 'chef-apply goodbye.rb --no-color --force-formatter' do
  cwd working_dir
  writer writers['step6']
end

control_group 'lesson1, step6' do
  control 'validate output' do
    describe file(writers['step6'].stdout_path) do
      its(:content) { should match /\s{2}\* file\[C:\\Users\\Administrator\\chef-repo\\settings.ini\] action delete/ }
      its(:content) { should match /\s{4}\- delete file C:\\Users\\Administrator\\chef-repo\\settings.ini/ }
    end
  end
  control 'validate result' do
    describe command("Test-Path #{settings_ini}") do
      its(:stdout) { should match /False$/ }
    end
  end
end

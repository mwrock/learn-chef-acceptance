#
# Cookbook Name:: learn-the-basics-windows
# Recipe:: _lesson2
#
# Copyright (c) 2015 The Authors, All Rights Reserved.
# Configure a package and service
working_dir = 'C:/Users/Administrator/chef-repo'

output_dir = 'C:/Users/Administrator/configure-a-package-and-service'

writers = Hash[%w(step1 step1_1 step2 step3 step4).map { 
  |step|[step, OutputPath.new(File.join(output_dir, step))] 
}]

directory output_dir do
  recursive true
end
writers.each_value do |writer|
  directory writer.base_path
end

directory working_dir do
  action [:create]
  recursive true
end

# 1. Install IIS
cookbook_file File.join(working_dir, 'webserver.rb') do
  source 'webserver_1.rb'
end

workflow_execute 'chef-apply webserver.rb --no-color --force-formatter' do
  cwd working_dir
  writer writers['step1']
end

workflow_execute 'chef-apply webserver.rb --no-color --force-formatter' do
  cwd working_dir
  writer writers['step1_1']
end

control_group 'lesson2, step1' do
  control 'validate output' do
    describe file(writers['step1'].stdout_path) do
      its(:content) { should match /^Recipe: \(chef-apply cookbook\)::\(chef-apply recipe\)$/ }
      its(:content) { should match /^\s{2}\* powershell_script\[Install IIS\] action run$/ }
      its(:content) { should match /^\s{4}\- execute "powershell\.exe" \-NoLogo \-NonInteractive \-NoProfile \-ExecutionPolicy RemoteSigned \-InputFormat None \-File$/ }
      its(:content) { should match /^"C:\/Users\/ADMINI~1\/AppData\/Local\/Temp\/chef\-script/}
    end
    describe file(writers['step1_1'].stdout_path) do
      its(:content) { should match /^\s{2}\* powershell_script\[Install IIS\] action run \(up to date\)$/ }
    end
  end
end

# 2. Start the World Wide Web Publishing Service
cookbook_file File.join(working_dir, 'webserver.rb') do
  source 'webserver_2.rb'
end

workflow_execute 'chef-apply webserver.rb --no-color --force-formatter' do
  cwd working_dir
  writer writers['step2']
end

control_group 'lesson2, step2' do
  control 'validate output' do
    describe file(writers['step2'].stdout_path) do
      its(:content) { should match /^\s{2}\* powershell_script\[Install IIS\] action run \(up to date\)$/ }
      its(:content) { should match /^\s{2}\* service\[w3svc\] action enable \(up to date\)$/ }
      its(:content) { should match /^\s{2}\* service\[w3svc\] action start \(up to date\)$/ }
    end
  end
end

# 3. Configure the home page
cookbook_file File.join(working_dir, 'webserver.rb') do
  source 'webserver_3.rb'
end

workflow_execute 'chef-apply webserver.rb --no-color --force-formatter' do
  cwd working_dir
  writer writers['step3']
end

control_group 'lesson2, step3' do
  control 'validate output' do
    describe file(writers['step3'].stdout_path) do
      its(:content) { should match /^\s{2}\* file\[c:\\inetpub\\wwwroot\\Default\.htm\] action create$/ }
      its(:content) { should match /^\s{4}\- update content in file/ }
      its(:content) { should match /^\s{4}\+\<html\>/ }
    end
  end
end

# 4. Confirm your web site is running
control_group 'lesson2, step4' do
  control 'validate output' do
    describe command('(Invoke-WebRequest localhost).Content') do
      its(:stdout) { should match <<-EOF.chomp
<html>
  <body>
    <h1>hello world</h1>
  </body>
</html>
EOF
}
    end
  end
end

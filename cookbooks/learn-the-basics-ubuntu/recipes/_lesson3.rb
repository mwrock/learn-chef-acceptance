#
# Cookbook Name:: learn-the-basics-ubuntu
# Recipe:: _lesson3
#
# Copyright (c) 2015 The Authors, All Rights Reserved.
# Make your recipe more manageable
repo_dir = File.join(ENV['HOME'], 'chef-repo')
cookbooks_dir = File.join(ENV['HOME'], 'chef-repo', 'cookbooks')

output_dir = File.join(ENV['HOME'], cookbook_name, 'make-your-recipe-more-manageable')

writers = Hash[%w(step1 step1_1 step2 step2_1 step3 step4).map { 
  |step|[step, OutputPath.new(File.join(output_dir, step))] 
}]

directory output_dir do
  recursive true
end
writers.each_value do |writer|
  directory writer.base_path
end

[repo_dir, cookbooks_dir].each do |dir|
  directory dir do
    action [:create]
    recursive true
  end
end

# 1. Create a cookbook
workflow_execute 'chef generate cookbook learn_chef_apache2' do
  cwd cookbooks_dir
  writer writers['step1']
end

workflow_execute 'tree' do
  cwd cookbooks_dir
  writer writers['step1_1']
end

control_group 'lesson3, step1' do
  control 'validate output' do
    describe file(writers['step1_1'].stdout_path) do
      its(:content) { should match /11 directories, 9 files/ }
    end
  end
end

# 2. Create a template
workflow_execute 'chef generate template learn_chef_apache2 index.html' do
  cwd cookbooks_dir
  writer writers['step2']
end

workflow_execute 'tree' do
  cwd cookbooks_dir
  writer writers['step2_1']
end

control_group 'lesson3, step2' do
  control 'validate output' do
    describe file(writers['step2_1'].stdout_path) do
        its(:content) { should match /13 directories, 10 files/ }
    end
  end
end

cookbook_file File.join(cookbooks_dir, 'learn_chef_apache2/templates/default/index.html.erb') do
  source 'index.html.erb'
end

# 3. Update the recipe to reference the HTML template
cookbook_file File.join(cookbooks_dir, 'learn_chef_apache2/recipes/default.rb') do
  source 'default_3.rb'
end

# 4. Run the cookbook
workflow_execute "sudo chef-client --local-mode --runlist 'recipe[learn_chef_apache2]' --no-color --force-formatter" do
  cwd repo_dir
  writer writers['step4']
end

control_group 'lesson3, step4' do
  control 'validate output' do
    describe file(writers['step4'].stdout_path) do
      its(:content) { should match /Starting Chef Client, version 12\.6/ }
      its(:content) { should match /Chef Client finished, 0\/4 resources updated in \d+ seconds/ }
    end
  end
end
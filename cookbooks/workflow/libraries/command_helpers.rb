module LearnChef module Workflow
  class CopyCookbookFile #< Chef::Recipe
    def initialize(source, destination)
      @source = source
      @destination = destination
    end
    def apply(context)
      # cookbook_file File.join(context.working_directory, @destination) do
      #   source @source
      # end
      r = Chef::Resource::CookbookFile.new(File.join(context.working_directory, @destination), context.run_context)
      r.source(@source)
      r.cookbook(context.cookbook_name)
      r.run_action(:create)
    end
  end

  class CacheFile
    def initialize(source_glob, relative_output_directory, preserve)
      @source_glob = source_glob
      @relative_output_directory = relative_output_directory
      @preserve = preserve
    end
    def apply(context)
      output_directory = File.join(context.cache_directory, @relative_output_directory)
      FileUtils.cp_r(@source_glob, output_directory, preserve: @preserve)
    end
  end

  class CacheCommand
    def initialize(command, relative_output_directory)
      @command = command
      @relative_output_directory = relative_output_directory
    end
    def apply(context)
      require 'open3'

      output_directory = File.join(context.cache_directory, @relative_output_directory)

      d = Chef::Resource::Directory.new(output_directory, context.run_context)
      d.recursive(true)
      d.run_action(:create)

      stdout_str, stderr_str, status = Open3.capture3(@command, chdir: File.join(context.working_directory))
      # file CachedHelpers.stdout_file(output_directory) do
      #   content stdout_str
      # end
      # file CachedHelpers.stderr_file(output_directory) do
      #   content stderr_str
      # end
      # file CachedHelpers.status_file(output_directory) do
      #   content status.exitstatus.to_s
      # end
      # file CachedHelpers.command_file(output_directory) do
      #   content command
      # end

      f1 = Chef::Resource::File.new(CachedHelpers.stdout_file(output_directory), context.run_context)
      f1.content(stdout_str)
      #f1.cookbook_name = context.cookbook_name
      f1.run_action(:create)

      f2 = Chef::Resource::File.new(CachedHelpers.stderr_file(output_directory), context.run_context)
      f2.content(stderr_str)
      #f2.cookbook_name = context.cookbook_name
      f2.run_action(:create)

      f3 = Chef::Resource::File.new(CachedHelpers.status_file(output_directory), context.run_context)
      f3.content(status.exitstatus.to_s)
      #f3.cookbook_name = context.cookbook_name
      f3.run_action(:create)

      f4 = Chef::Resource::File.new(CachedHelpers.command_file(output_directory), context.run_context)
      f4.content(@command)
      #f4.cookbook_name = context.cookbook_name
      f4.run_action(:create)
    end
  end

  class CachedHelpers
    def self.stdout_file(path)
      File.join(path, 'stdout')
    end
    def self.stderr_file(path)
      File.join(path, 'stderr')
    end
    def self.status_file(path)
      File.join(path, 'status')
    end
    def self.command_file(path)
      File.join(path, 'command')
    end
    def self.normalize_matchers(matchers, variables)
      # unpack if matchers is already an array.
      # each element might refer to either a string or a symbol.
      return matchers.map{|matcher| normalize_matchers(matcher, variables)}.flatten if matchers.respond_to?('each')

      # map symbol name to entry in variables Hash if matchers is a symbol.
      return normalize_matchers(variables[matchers], variables) if matchers.is_a? Symbol

      # convert to single-element array if scalar.
      [matchers]
    end
  end

  class CachedStdout
    def initialize(relative_output_directory, expectation, matchers)
      @relative_output_directory = relative_output_directory
      @expectation = expectation
      @matchers = matchers
    end
    def apply(context)
      # stdout_file = CachedHelpers.stdout_file(File.join(context.cache_directory, @output_directory))
      # control 'verify stdout' do
      #   describe file(stdout_file) do
      #     CachedHelpers.normalize_matchers(matchers, context.variables)
      #     its (:content) { should match matcher }
      #   end
      # end
    end
  end

end; end

Chef::Recipe.send(:include, LearnChef::Workflow)

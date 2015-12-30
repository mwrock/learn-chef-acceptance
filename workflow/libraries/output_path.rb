module LearnChef module Workflow
  class OutputPath
    attr_reader :base_path
    attr_reader :command_path
    attr_reader :stdout_path
    attr_reader :stderr_path
    attr_reader :status_path

    def initialize(path)
      @base_path = path
      @command_path = File.join(path, 'command')
      @stdout_path = File.join(path, 'stdout')
      @stderr_path = File.join(path, 'stderr')
      @status_path = File.join(path, 'status')
    end
  end
end; end

Chef::Recipe.send(:include, LearnChef::Workflow)

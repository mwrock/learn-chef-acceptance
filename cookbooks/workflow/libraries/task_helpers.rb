module LearnChef module Workflow
  class TaskContext
    attr_reader :working_directory
    attr_reader :cache_directory
    attr_reader :variables
    attr_reader :run_context
    attr_reader :cookbook_name
    
    def initialize(working_directory, cache_directory, variables, run_context, cookbook_name)
      @working_directory = working_directory
      @cache_directory = cache_directory
      @variables = variables
      @run_context = run_context
      @cookbook_name = cookbook_name
    end
  end

  class TaskHelper
    def initialize(context)
      @context = context
    end

    def apply_commands(commands)
      if commands.respond_to?('each')
        commands.each do |command|
          command.apply(@context)
        end
      else
        # commands is a scalar.
        commands.apply(@context)
      end
    end
  end
end; end

Chef::Recipe.send(:include, LearnChef::Workflow)

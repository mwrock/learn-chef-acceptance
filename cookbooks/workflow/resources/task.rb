require 'open3'
require_relative '../libraries/output_path.rb'
require_relative '../libraries/task_helpers.rb'
require_relative '../libraries/command_helpers.rb'

property :control_group_name, kind_of: String, name_property: true
property :working_directory, kind_of: String, required: true
property :cache_directory, kind_of: String, required: true
property :before, kind_of: Object, default: nil, required: false
property :commands, kind_of: [Object, Array], default: [], required: false
property :after, kind_of: Object, default: nil, required: false
property :validates, kind_of: Object, default: nil, required: false
property :audits, kind_of: [Object, Array], default: [], required: false
property :variables, kind_of: Hash, default: {}, required: false

action :run do
  context = LearnChef::Workflow::TaskContext.new(
    working_directory,
    cache_directory,
    variables,
    run_context,
    cookbook_name
  )

  apply_commands(before, context) unless before.nil?
  apply_commands(commands, context) unless commands.nil?
  apply_commands(after, context) unless after.nil?

  audits2 = [audits].flatten.reject {|a| a.nil?}
  puts "$$$$$$2"
  puts audits2
  unless audits2.empty?
    puts "$$$$$$3"
    control_group control_group_name do
      audits2.each do |audit|
        case audit[:subject]
        when :stdout
          audit_stdout(context, audit[:directory], audit[:verb], audit[:matchers])
        end
      end
    end
  end

  #apply_audits([audits].flatten.reject {|a| a.nil?}, context) unless audits.nil?
  # unless validates.nil?
  #   control_group control_group_name do
  #     apply_commands(validates, context)
  #   end
  # end

  #{ subject: :stdout, directory: './2', verb: :matches, targets: :expected_stdout },
  #{ subject: :stdout, directory: './2/more', verb: :matches, /^hello world$/ }

  # stdout_str, stderr_str, status = Open3.capture3(command, chdir: cwd)
  # file writer.stdout_path do
  #   content stdout_str
  # end
  # file writer.stderr_path do
  #   content stderr_str
  # end
  # file writer.status_path do
  #   content status.exitstatus.to_s
  # end
  # file writer.command_path do
  #   content command
  # end
end

def copy_cookbook_file(source, destination)
  LearnChef::Workflow::CopyCookbookFile.new(source, destination)
end

def cache_command(command, relative_output_directory)
  LearnChef::Workflow::CacheCommand.new(command, relative_output_directory)
end

def cache_file(source_glob, relative_output_directory, preserve = true)
  LearnChef::Workflow::CacheFile.new(source_glob, relative_output_directory, preserve)
end

def cached_stdout(relative_output_directory, expectation, matchers)
  LearnChef::Workflow::CachedStdout.new(relative_output_directory, expectation, matchers)
end

def audit_stdout(context, directory, verb, matchers)
  stdout_file = CachedHelpers.stdout_file(File.join(context.cache_directory, directory))
  control "verify #{stdout_file}" do
    describe file(stdout_file) do
      CachedHelpers.normalize_matchers(matchers, context.variables).each do |matcher|
        case verb
        when :match
          puts "HI!!222"
          its (:content) { should match matcher }
        end
      end
    end
  end
end

# def apply_audits(audits, context)
#   puts "$$$$$$2"
#   puts audits
#   unless audits.empty?
#     puts "$$$$$$3"
#     control_group control_group_name do
#       audits.each do |audit|
#         case audit[:subject]
#         when :stdout
#           audit_stdout(context, audit[:directory], audit[:verb], audit[:matchers])
#         end
#       end
#     end
#   end
# end

def apply_commands(commands, context)
  if commands.respond_to?('each')
    commands.each do |command|
      command.apply(context)
    end
  else
    # commands is a scalar.
    commands.apply(context)
  end
end

require 'open3'
include LearnChef::Workflow

# this is used to name the subdirectory where the output (stdout, stderr, exit code) is written.
property :name, String, name_property: true
# the command to run.
property :command, String, required: true
# the directory to run the command.
property :cwd, String, required: true
# directory to write output to.
property :cache, String, required: false, default: nil
# the shell to run the command from. options are :bash and :powershell.
property :shell, Symbol, required: false, default: nil

action :run do
  # Ensure working directory exists.
  directory cwd do
    recursive true
  end

  options = {}

  # Generate final command to run.
  user_shell = shell || current_shell
  case user_shell
  when :bash
    # If bash, just pass through.
    cmd = command
    options[:chdir] = cwd unless cwd.nil?
  when :powershell
    # If powershell, write the command to a temporary script.
    script_path = ::File.join(cwd, "#{crc(command)}.ps1")
    file script_path do
      content command
    end
    cmd = "powershell.exe \"& \"\"#{script_path}\"\"\""

    puts "\n\n\n\n\n\n\n\n\n#{cmd}\n\n\n\n\n\n\n\n\n"
    # Don't set options[:chdir]
  end

  # Run the command.å
  stdout_str, stderr_str, status = Open3.capture3(cmd, options)

  # Write the result to disk.
  unless cache.nil?
    # Ensure cache directory exists.
    directory ::File.join(cache, name) do
      recursive true
    end

    # Write stdout.
    file stdout_file(cache, name) do
      content stdout_str
    end
    # Write stderr.
    file stderr_file(cache, name) do
      content stderr_str
    end
    # Write exit code.
    file status_file(cache, name) do
      content status.exitstatus.to_s
    end
    # Write the command (helps with debugging).
    file command_file(cache, name) do
      content command
    end
  end
end

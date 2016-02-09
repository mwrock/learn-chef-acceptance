include LearnChef::Workflow
include Chef::Mixin::ShellOut

# this is used to name the subdirectory where the output (stdout, stderr, exit code) is written.
property :name, String, name_property: true
# the command to run.
property :command, String, required: true
# the directory to run the command.
property :cwd, String, required: true
# directory to write output to.
property :cache, String, required: false, default: nil
# the shell to run the command from. options are :bash and :powershell.
property :shell, Symbol, required: false, default: :current

action :run do
  # Ensure working directory exists.
  directory cwd do
    recursive true
  end

  # Generate final command to run.
  user_shell = (shell == :current) ? current_shell : shell
  case user_shell
  when :bash
    cmd = command
  when :powershell
    cmd = "powershell.exe -Command \"#{command}\""
  end

  # Run the command.
  log "Run #{user_shell} command '#{cmd}'"
  result = shell_out(cmd, cwd: cwd)

  # Write the result to disk.
  unless cache.nil?
    # Ensure cache directory exists.
    directory ::File.join(cache, name) do
      recursive true
    end

    # Write stdout.
    file stdout_file(cache, name) do
      content result.stdout
    end
    # Write stderr.
    file stderr_file(cache, name) do
      content result.stderr
    end
    # Write exit code.
    file status_file(cache, name) do
      content result.exitstatus.to_s
    end
    # Write the command (helps with debugging).
    file command_file(cache, name) do
      content command
    end
  end
end

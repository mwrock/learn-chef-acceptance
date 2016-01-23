module LearnChef module Workflow
  def stdout_file(*paths)
    File.join(paths, 'stdout')
  end

  def stderr_file(*paths)
    File.join(paths, 'stderr')
  end

  def status_file(*paths)
    File.join(paths, 'status')
  end

  def command_file(*paths)
    File.join(paths, 'command')
  end
end; end

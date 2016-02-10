module LearnChef module Workflow
  @@task_options = {}

  def assign_task_options(options)
    @@task_options = options
  end

  def task_options
    @@task_options
  end
end; end

include LearnChef::Workflow

# directory to write output to.
property :cache, String, required: false, default: nil
# the shell to run the command from. options are :bash and :powershell.
property :shell, Symbol, required: false, default: :bash
# a Hash of environment variables to set before the command is run.
property :environment, Hash, required: false, default: {}

action :set do
  assign_task_options(
    cache: cache,
    shell: shell,
    environment: environment
    )
end

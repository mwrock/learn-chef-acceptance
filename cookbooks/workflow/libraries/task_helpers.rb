module LearnChef module Workflow
  def with_shell(shell)
    @@current_shell = shell
  end

  def current_shell
    @@current_shell || @@default_shell
  end

  def crc(s)
    require 'zlib'
    Zlib.crc32 s
  end

private
  @@default_shell = 'bash'
end; end

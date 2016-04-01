module CrCfnInit
  class Error < Exception
    class CommandFailed < Error; end
    class CommandTestFailed < Error; end
    class CommandNotRun < Error; end

    class CommandsAlreadyExecuted < Error; end
  end
end

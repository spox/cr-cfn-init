module CrCfnInit
  class Error < Exception
    class CommandFailed < Error; end
    class CommandTestFailed < Error; end
    class CommandNotRun < Error; end

    class CommandsAlreadyExecuted < Error; end

    class FileDefinitionInvalid < Error; end
    class FileWriteAlreadyPerformed < Error; end
    class FileAttributeFailure < Error; end
    class FileWriteFailure < Error; end
    class FileSourceDownloadFailed < Error; end
  end
end

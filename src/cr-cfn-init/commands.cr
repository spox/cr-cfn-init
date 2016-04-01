require "./error"

module CrCfnInit

  # Collection of Command instances
  class Commands

    # Single command unit
    class Command
      @result : Process::Status?

      getter name
      getter command
      getter test
      getter env
      getter cwd
      getter ignore_errors
      getter wait_after_completion

      # Create a new command instance
      #
      # @param name [String] name of this command
      # @param command [String] command to run
      # @param test [String] only run if this command is true
      # @param env [Process::Env] custom environment variables
      # @param cwd [String] current working directory
      # @param ignore_errors [Bool] do not raise exception on failure
      # @param wait_after_completion [Int32] number of seconds to wait after successful command
      #
      # @return [self]
      def initialize(
            @name : String,
            @command : String,
            @test : String = "",
            @env : Process::Env = nil,
            @cwd : (String | Nil) = nil,
            @ignore_errors : Bool = false,
            @wait_after_completion : Int32? = nil
          )
        @result = nil
      end

      # If test is provided, does test return true
      # allowing command to run
      #
      # @return [Bool]
      def should_run? : Bool
        unless(@test.empty?)
          Process.run(
            @test, nil, @env, true, true, nil, nil, @cwd
          ).success?
        else
          true
        end
      end

      # @return [Bool] command has been run
      def has_run? : Bool
        !@result.nil?
      end

      # @return [Bool] command has been run and was successful
      def success? : Bool
        result = @result
        if(has_run? && result)
          result.success?
        else
          raise Error::CommandNotRun.new("Command has not been run!")
        end
      end

      # Run defined command
      #
      # @return [Bool] command was successful
      def run
        unless(has_run?)
          @result = Process.run(
            @command, nil, @env, true, true, nil, nil, @cwd
          )
          wait_time = @wait_after_completion
          if(success? && wait_time)
            sleep(wait_time)
          end
        end
        if(!@ignore_errors && !success?)
          raise Error::CommandFailed.new("Command returned non-zero exit code!")
        else
          success?
        end
      end

    end

    @commands : Array(Command)
    @executed : Bool

    getter commands

    # Create a new collection of commands
    #
    # @param init [Array<Hash(String, String | Bool | Int32 | Process::Env)>] commands data
    # @return [self]
    def initialize(init : Array(Hash(String, String | Bool | Int32 | Process::Env)))
      @executed = false
      @commands = init.map do |item|
        args = [
          item["name"],
          item["command"],
          item.fetch("test", nil),
          item.fetch("env", nil),
          item.fetch("cwd", nil),
          item.fetch("ignore_errors", nil),
          item.fetch("wait_after_completion", nil)
        ].compact
        Command.new(*args.values_at(0, args.size - 1))
      end.sort_by do |item|
        item.name
      end
    end

    # Run all commands
    #
    # @return [Bool]
    def execute! : Bool
      unless(executed?)
        @executed = true
        @commands.each do |cmd|
          cmd.run if cmd.should_run?
        end
        true
      else
        raise Error::CommandsAlreadyExecuted.new("Commands have already been executed!")
      end
    end

    # @return [Bool] commands have been executed
    def executed? : Bool
      @executed
    end

  end
end

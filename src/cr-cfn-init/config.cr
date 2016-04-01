require "json"
require "./commands"

module CrCfnInit

  # Configuration item
  class Config

    @name : String
    @commands : Commands

    getter name
    getter commands

    # Create a new configuration item
    #
    # @param name [String]
    # @param init [JSON::Type, Hash(String, Array(Hash(String, String))]
    #
    # @return [self]
    def initialize(
          @name : String,
          @commands : Commands = Commands.new([] of Hash(String, String))
        )
    end

  end
end

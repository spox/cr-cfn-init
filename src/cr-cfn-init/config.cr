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
    def initialize(@name : String, init : JSON::Type | Hash(String, Array(Hash(String, String))))
      @commands = Commands.new(init.fetch("commands", Array(Hash(String, String)).new))
    end

  end
end

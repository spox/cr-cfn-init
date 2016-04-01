require "./spec_helper"

describe CrCfnInit::Config do

  it "should create an empty config" do
    config = CrCfnInit::Config.new("fubar")
    config.commands.commands.empty?.should be_true
  end

  it "should create a config with commands" do
    cmds = [
      {"name" => "fubar", "command" => "/bin/true"},
      {"name" => "ack", "command" => "/bin/true"}
    ]
    commands = CrCfnInit::Commands.new(cmds)
    config = CrCfnInit::Config.new("fubar", commands)
    config.commands.commands.empty?.should be_false
  end

end

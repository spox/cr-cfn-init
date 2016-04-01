require "./spec_helper"

describe CrCfnInit::Commands do

  it "should create a collection of commands" do
    cmds = [
      {"name" => "fubar", "command" => "/bin/true"},
      {"name" => "ack", "command" => "/bin/true"}
    ]
    commands = CrCfnInit::Commands.new(cmds)
    commands.commands.should be_a(Array(CrCfnInit::Commands::Command))
  end

  it "should create an empty collection of commands" do
    cmds = [] of Hash(String, String)
    commands = CrCfnInit::Commands.new(cmds)
    commands.commands.empty?.should be_true
  end

  it "should string order the commands automatically" do
    cmds = [
      {"name" => "10_cmd", "command" => "/bin/true"},
      {"name" => "01_cmd", "command" => "/bin/true"},
      {"name" => "03_cmd", "command" => "/bin/true"}
    ]
    commands = CrCfnInit::Commands.new(cmds)
    commands.commands[0].name.should eq("01_cmd")
    commands.commands[1].name.should eq("03_cmd")
    commands.commands[2].name.should eq("10_cmd")
  end

  it "should execute commands successfully" do
    cmds = [
      {"name" => "10_cmd", "command" => "/bin/true"},
      {"name" => "01_cmd", "command" => "/bin/true"},
      {"name" => "03_cmd", "command" => "/bin/true"}
    ]
    commands = CrCfnInit::Commands.new(cmds)
    commands.execute!.should be_true
  end

  it "should raise exception when a command fails to execute" do
    cmds = [
      {"name" => "10_cmd", "command" => "/bin/true"},
      {"name" => "01_cmd", "command" => "/bin/true"},
      {"name" => "03_cmd", "command" => "/bin/false"}
    ]
    commands = CrCfnInit::Commands.new(cmds)
    expect_raises(CrCfnInit::Error::CommandFailed){ commands.execute! }
  end

  it "should raise expcetion if executed after already executed" do
    cmds = [
      {"name" => "10_cmd", "command" => "/bin/true"},
      {"name" => "01_cmd", "command" => "/bin/true"},
      {"name" => "03_cmd", "command" => "/bin/true"}
    ]
    commands = CrCfnInit::Commands.new(cmds)
    commands.execute!.should be_true
    expect_raises(CrCfnInit::Error::CommandsAlreadyExecuted){ commands.execute! }
  end

  it "should show commands as executed" do
    cmds = [
      {"name" => "10_cmd", "command" => "/bin/true"},
      {"name" => "01_cmd", "command" => "/bin/true"},
      {"name" => "03_cmd", "command" => "/bin/true"}
    ]
    commands = CrCfnInit::Commands.new(cmds)
    commands.executed?.should be_false
    commands.execute!.should be_true
    commands.executed?.should be_true
  end

  it "should include test value when provided" do
    cmds = [
      {"name" => "10_cmd", "command" => "/bin/true"},
      {"name" => "01_cmd", "command" => "/bin/false", "test" => "/bin/false"},
      {"name" => "03_cmd", "command" => "/bin/true"}
    ]
    commands = CrCfnInit::Commands.new(cmds)
    commands.execute!.should be_true
  end

  it "should include environment when provided" do
    cmds = [
      {"name" => "01_cmd", "command" => "test \"$CR_TEST\" = \"test_value\"", "env" => {"CR_TEST" => "test_value"}}
    ]
    commands = CrCfnInit::Commands.new(cmds)
    commands.execute!.should be_true
  end

  it "should include cwd when provided" do
    cmds = [
      {"name" => "01_cmd", "command" => "test \"$PWD\" = \"/tmp\"", "cwd" => "/tmp"}
    ]
    commands = CrCfnInit::Commands.new(cmds)
    commands.execute!.should be_true
  end

  it "should ignore errors when told to ignore errors" do
    cmds = [
      {"name" => "01_cmd", "command" => "/bin/false", "ignore_errors" => true},
      {"name" => "02_cmd", "command" => "/bin/true"}
    ]
    commands = CrCfnInit::Commands.new(cmds)
    commands.execute!.should be_true
  end

  it "should wait after commands completes if told to wait" do
    cmds = [
      {"name" => "01_cmd", "command" => "/bin/true", "wait_after_completion" => 1},
      {"name" => "02_cmd", "command" => "/bin/true"}
    ]
    commands = CrCfnInit::Commands.new(cmds)
    start = Time.now.epoch_f
    commands.execute!.should be_true
    stop = Time.now.epoch_f
    elapsed = stop - start
    elapsed.should be_close(1.0, 0.2)
  end

end

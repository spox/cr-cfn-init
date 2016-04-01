require "./spec_helper"

describe CrCfnInit::Commands::Command do

  describe "with command only" do

    it "should create a new command instance with name and command" do
      cmd = CrCfnInit::Commands::Command.new("fubar", "/bin/true")
      cmd.name.should eq("fubar")
      cmd.command.should eq("/bin/true")
    end

    it "should run command instance" do
      cmd = CrCfnInit::Commands::Command.new("fubar", "/bin/true")
      cmd.run.should be_true
    end

    it "should always run" do
      cmd = CrCfnInit::Commands::Command.new("fubar", "/bin/true")
      cmd.should_run?.should be_true
    end

    it "should show if command has been run" do
      cmd = CrCfnInit::Commands::Command.new("fubar", "/bin/true")
      cmd.has_run?.should be_false
      cmd.run
      cmd.has_run?.should be_true
    end

    it "should show command success" do
      cmd = CrCfnInit::Commands::Command.new("fubar", "/bin/true")
      cmd.run
      cmd.success?.should be_true
    end

    it "should raise exception when command fails" do
      cmd = CrCfnInit::Commands::Command.new("fubar", "/bin/false")
      expect_raises(CrCfnInit::Error::CommandFailed){ cmd.run }
    end

  end

  describe "with command and test" do

    it "should return test command value" do
      cmd = CrCfnInit::Commands::Command.new("fubar", "/bin/true", "/bin/true")
      cmd.test.should eq("/bin/true")
    end

    it "should run with positive test" do
      cmd = CrCfnInit::Commands::Command.new("fubar", "/bin/true", "/bin/true")
      cmd.should_run?.should be_true
    end

    it "should not run with negative test" do
      cmd = CrCfnInit::Commands::Command.new("fubar", "/bin/true", "/bin/false")
      cmd.should_run?.should be_false
    end

  end

  describe "with command and env" do

    it "should return env value" do
      cmd = CrCfnInit::Commands::Command.new("fubar", "/bin/true", "/bin/false", {"CR_TEST" => "test_value"})
      cmd.env.should eq({"CR_TEST" => "test_value"})
    end

    it "should have access to env value" do
      cmd = CrCfnInit::Commands::Command.new("fubar", "test \"$CR_TEST\" = \"test_value\"", "/bin/true", {"CR_TEST" => "test_value"})
      cmd.run.should be_true
    end

  end

  describe "with command and cwd" do

    it "should return cwd value" do
      cmd = CrCfnInit::Commands::Command.new("fubar", "/bin/true", "/bin/false", nil, "/tmp")
      cmd.cwd.should eq("/tmp")
    end

    it "should execute command within defined cwd" do
      cmd = CrCfnInit::Commands::Command.new("fubar", "test \"$PWD\" = \"/tmp\"", "/bin/false", nil, "/tmp")
      cmd.run.should be_true
    end

  end

  describe "with command and ignore errors" do

    it "should return ignore errors value" do
      cmd = CrCfnInit::Commands::Command.new("fubar", "/bin/true", nil, nil, nil, true)
      cmd.ignore_errors.should be_true
    end

    it "should not raise exception when command fails" do
      cmd = CrCfnInit::Commands::Command.new("fubar", "/bin/false", nil, nil, nil, true)
      cmd.run.should be_false
    end

    it "should not show success when command fails" do
      cmd = CrCfnInit::Commands::Command.new("fubar", "/bin/false", nil, nil, nil, true)
      cmd.run.should be_false
      cmd.success?.should be_false
    end

  end

  describe "with command and wait after completion" do

    it "should return wait after completion value" do
      cmd = CrCfnInit::Commands::Command.new("fubar", "/bin/true", nil, nil, nil, false, 1)
      start = Time.now.epoch_f
      cmd.run.should be_true
      stop = Time.now.epoch_f
      elapsed = stop - start
      elapsed.should be_close(1.0, 0.2)
    end

  end

end

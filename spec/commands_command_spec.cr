require "./spec_helper"

describe CrCfnInit::Commands::Command do

  it "should create a new command instance" do
    cmd = CrCfnInit::Commands::Command.new("fubar", "/bin/true")
    cmd.command.should eq("/bin/true")
  end

end

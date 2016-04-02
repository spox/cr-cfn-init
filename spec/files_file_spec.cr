require "./spec_helper"

describe CrCfnInit::Files::File do

  it "should create empty file instance with path" do
    file = CrCfnInit::Files::File.new("/tmp/file.txt")
    file.path.should eq("/tmp/file.txt")
    file.content.nil?.should be_true
    file.source.nil?.should be_true
    file.encoding.should eq("plain")
    file.group.should eq(ENV.fetch("USER", "root"))
    file.owner.should eq(ENV.fetch("USER", "root"))
    file.mode.should eq("000644")
  end

  it "should create file at path with content" do
    content = "test content - #{rand}"
    file = CrCfnInit::Files::File.new("/tmp/cr-cfn-init-file.txt", content)
    file.write!.should be_true
    File.exists?("/tmp/cr-cfn-init-file.txt").should be_true
    new_content = File.read("/tmp/cr-cfn-init-file.txt")
    new_content.should eq(content)
    File.delete(file.path)
  end

  it "should overwrite contents of existing file" do
    File.write("/tmp/cr-cfn-init-file.txt", "default content")
    File.read("/tmp/cr-cfn-init-file.txt").should eq("default content")
    content = "test content - #{rand}"
    file = CrCfnInit::Files::File.new("/tmp/cr-cfn-init-file.txt", content)
    file.write!.should be_true
    File.read("/tmp/cr-cfn-init-file.txt").should eq(content)
    File.delete(file.path)
  end

  it "should generate a symlink" do
    File.write("/tmp/cr-cfn-init-file.txt.base", "default content")
    File.read("/tmp/cr-cfn-init-file.txt.base").should eq("default content")
    file = CrCfnInit::Files::File.new(
      "/tmp/cr-cfn-init-file.txt",
      "/tmp/cr-cfn-init-file.txt.base",
      nil, nil, nil, nil, "12000"
    )
    file.write!.should be_true
    File.symlink?("/tmp/cr-cfn-init-file.txt").should be_true
    File.read("/tmp/cr-cfn-init-file.txt").should eq("default content")
    File.delete("/tmp/cr-cfn-init-file.txt")
    File.delete("/tmp/cr-cfn-init-file.txt.base")
  end

  it "should write content from source" do
    file = CrCfnInit::Files::File.new(
      "/tmp/cr-cfn-init-file.txt",
      nil, "https://github.com/spox"
    )
    file.write!.should be_true
    File.read("/tmp/cr-cfn-init-file.txt").includes?("spox").should be_true
    File.delete("/tmp/cr-cfn-init-file.txt")
  end

end

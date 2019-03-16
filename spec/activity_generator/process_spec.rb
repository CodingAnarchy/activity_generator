RSpec.describe ActivityGenerator::Process do
  it "starts a process when created" do
    expect(described_class.new('ls').pid).to_not be_nil
  end

  it "records the proctable data for the started process" do
    expect(described_class.new('ls').data).to_not be_nil
  end

  describe "#to_yaml" do
    it "returns a YAML structure for the process data" do
      expect{YAML.load(described_class.new('ls').to_yaml)}.to_not raise_error
    end
  end
end

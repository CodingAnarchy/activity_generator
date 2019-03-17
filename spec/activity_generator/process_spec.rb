RSpec.describe ActivityGenerator::Process do
  it "starts a process when created" do
    expect(described_class.new('ls').pid).to_not be_nil
  end

  it "records the proctable data for the started process" do
    expect(described_class.new('ls').data).to_not be_nil
  end
end

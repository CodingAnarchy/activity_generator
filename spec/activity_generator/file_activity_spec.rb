RSpec.describe ActivityGenerator::FileActivity do
  after :each do
    FileUtils.rm_f('/tmp/test')
  end

  context "creating a file" do
    it "leaves the created file" do
      described_class.new('create', '/tmp/test')
    end
  end
end

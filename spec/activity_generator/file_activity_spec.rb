RSpec.describe ActivityGenerator::FileActivity do
  after :each do
    FileUtils.rm_f('/tmp/test')
    FileUtils.rm_f('/tmp/test.sock') if File.exist?('/tmp/test.sock')
  end

  context "creating a file" do
    it "leaves the created file" do
      described_class.new('create', '/tmp/test')
      Process.wait # wait for the processes created to complete
      expect(File.file?('/tmp/test')).to be true
    end
  end

  context "creating a socket" do
    it "creates a socket file" do
      described_class.new('create', '/tmp/test.sock', file_type: 'socket')
      expect(File.socket?('/tmp/test.sock')).to be true
    end
  end
end

RSpec.describe ActivityGenerator::FileActivity do
  context "creation" do
    context "file" do
      after :each do
        FileUtils.rm_f('/tmp/test.sock')
      end

      it "leaves the created file" do
        described_class.new('create', '/tmp/test')
        Process.wait # wait for the processes created to complete
        expect(File.file?('/tmp/test')).to be true
      end
    end

    context "socket" do
      after :each do
        FileUtils.rm_f('/tmp/test.sock')
      end

      it "creates a socket file" do
        described_class.new('create', '/tmp/test.sock', file_type: 'socket')
        expect(File.socket?('/tmp/test.sock')).to be true
      end

      it "contains the process data for the Ruby process" do
        # Convert both to hash to ignore data that changes due to timestamp of running the `ps` process
        expect(described_class.new('create', '/tmp/test.sock', file_type: 'socket').process_data.to_hash).to eq(ActivityGenerator::ProcessData.new(Sys::ProcTable.ps(pid: ::Process.pid)).to_hash)\
      end
    end

    context "directory" do
      after :each do
        FileUtils.rm_r('/tmp/test_dir')
      end

      it "creates a directory" do
        described_class.new('create', '/tmp/test_dir', file_type: 'dir')
        Process.wait # wait for the processes created to complete
        expect(File.directory?('/tmp/test_dir')).to be true
      end
    end

    context "pipe" do
      after :each do
        FileUtils.rm_f('/tmp/pipe')
      end

      it "creates a named pipe" do
        described_class.new('create', '/tmp/pipe', file_type: 'pipe')
        Process.wait # wait for the processes created to complete
        expect(File.pipe?('/tmp/pipe')).to be true
      end
    end
  end
end

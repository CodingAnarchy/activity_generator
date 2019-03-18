RSpec.describe ActivityGenerator::FileActivity do
  context "creation" do
    context "file" do
      after :each do
        FileUtils.rm_f('/tmp/test')
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

  context "modify" do
    %w(file socket pipe dir).each do |file_type|
      context "#{file_type}" do
        before :each do
          described_class.new('create', '/tmp/test', file_type: file_type)
          Process.wait unless file_type == "socket" # Skip for sockets, which are created in Ruby process
        end

        after :each do
          FileUtils.rm_r('/tmp/test')
        end

        it "modifies the file's timestamps" do
          expect{
            sleep(2) # Wait a bit so the timestamps definitely should be different
            described_class.new('modify', '/tmp/test')
            Process.wait
          }.to change{File.mtime('/tmp/test')}
        end
      end
    end
  end

  context "delete" do
    context "file" do
      before :each do
        FileUtils.touch('/tmp/test')
      end

      it "deletes the file" do
        expect(File.exist?('/tmp/test')).to be true
        described_class.new('delete', '/tmp/test')
        Process.wait
        expect(File.exist?('/tmp/test')).to be false
      end
    end

    context "socket" do
      before :each do
        UNIXServer.new('/tmp/test.sock')
      end

      it "removes the socket file" do
        expect(File.exist?('/tmp/test.sock')).to be true
        described_class.new('delete', '/tmp/test.sock')
        Process.wait
        expect(File.exist?('/tmp/test.sock')).to be false
      end
    end

    context "fifo" do
      before :each do
        `mkfifo /tmp/pipe`
      end

      it "removes the fifo file" do
        expect(File.pipe?('/tmp/pipe')).to be true
        described_class.new('delete', '/tmp/pipe')
        Process.wait
        expect(File.exist?('/tmp/pipe')).to be false
      end
    end

    context "directory" do
      before :each do
        FileUtils.mkdir_p('/tmp/test_dir')
      end

      it "removes the directory" do
        expect(File.directory?('/tmp/test_dir')).to be true
        described_class.new('delete', '/tmp/test_dir')
        Process.wait
        expect(File.exist?('/tmp/test_dir')).to be false
      end
    end
  end
end

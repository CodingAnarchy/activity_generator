RSpec.describe ActivityGenerator::NetworkActivity do
  context "http" do
    it "successfully completes the data upload" do
      described_class.new(transmit_filepath: TEST_FILE)
      expect($?&.success?).to be true
    end

    it "successfully completes the download" do
      described_class.new
      expect($?&.success?).to be true
    end
  end

  # Have to skip on linux automated testing; travis CI infrastructure doesn't work for FTP on linux
  # See: https://blog.travis-ci.com/2018-07-23-the-tale-of-ftp-at-travis-ci
  context "ftp", skip: OS.linux? do
    it "successfully completes an upload" do
      described_class.new(remote_addr: "ftp://anonymous:test@speedtest.tele2.net/upload/", transmit_filepath: TEST_FILE)
      expect($?&.success?).to be true
    end

    context "download" do
      before { described_class.new(remote_addr: "ftp://anonymous:test@speedtest.tele2.net/", transmit_filepath: '/tmp/ftp_download_test', download_filename: "100MB.zip") }
      after { FileUtils.rm_f('/tmp/ftp_download_test') }

      it "successfully completes a download" do
        expect($?.success?).to be true
      end

      it "downloads the file to the specified location" do
        expect(File.exists?('/tmp/ftp_download_test')).to be true
      end
    end
  end
end

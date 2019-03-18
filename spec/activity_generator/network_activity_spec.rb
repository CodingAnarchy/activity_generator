RSpec.describe ActivityGenerator::NetworkActivity do
  context "upload" do
    it "successfully completes the data transfer" do
      described_class.new(transmit_filepath: TEST_FILE)
      expect($?&.success?).to be true
    end
  end

  context "download" do
    it "successfully completes the data transfer" do
      described_class.new
      expect($?&.success?).to be true
    end
  end
end

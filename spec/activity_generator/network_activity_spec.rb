RSpec.describe ActivityGenerator::NetworkActivity do
  context "upload" do
    it "successfully completes the data transfer" do
      described_class.new
      Process.wait
      expect($?&.success?).to be true
    end
  end

  context "download" do
    it "successfully completes the data transfer" do
      described_class.new(upload: false)
      Process.wait
      expect($?&.success?).to be true
    end
  end
end

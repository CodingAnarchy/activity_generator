RSpec.describe ActivityGenerator::NetworkActivity do
  context "upload" do
    it "successfully completes the data transfer" do
      described_class.new
      Process.wait
      expect($?&.success?).to be true
    end
  end
end

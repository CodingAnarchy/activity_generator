RSpec.describe ActivityGenerator::Runner do
  context "with test input file" do
    it "runs the file through without error" do
      expect {
        described_class.new(file: File.expand_path("spec/fixtures/process_run.yaml"))
      }.to_not raise_error
    end
  end
end

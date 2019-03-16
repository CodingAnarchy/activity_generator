RSpec.describe ActivityGenerator::ProcessData do
  subject { ActivityGenerator::Process.new('ls').data }
  
  describe "#start_time" do
    it "returns a realistic start time for the process" do
      expect(subject.start_time).to be_between(2.minutes.ago.to_i, Time.now.to_i)
    end
  end
end

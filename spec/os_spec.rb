RSpec.describe OS do
  context "RUBY_PLATFORM is darwin" do
    before :each do
      allow_any_instance_of(Object).to receive(RUBY_PLATFORM).and_return('darwin')
    end

    describe ".mac?" do
      it "returns true if the system is darwin based" do
        expect(OS.mac?).to be true
      end
    end
  end
end

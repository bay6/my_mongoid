describe "Should be able to configure MyMongoid:" do
  describe "MyMongoid::Configuration" do
    let(:config) {
      MyMongoid::Configuration.instance
    }

    it "should be a singleton class" do
      config2 = MyMongoid::Configuration.instance
      expect(config).to eq(config2)
      expect{
        MyMongoid::Configuration.new
      }.to raise_error(NoMethodError)
    end

    it "should have #host accessor" do
      expect{
        config.host
      }.not_to raise_error
    end

    it "should have #database accessor" do
      expect{
        config.database
      }.not_to raise_error
    end
  end

  describe "MyMongoid.configuration" do
    it "should return the MyMongoid::Configuration singleton" do
      config = MyMongoid.configuration
      expect(config).to be_a(MyMongoid::Configuration) 
    end
  end

  describe "MyMongoid.configure" do
    it "should yield MyMongoid.configuration to a block" do
      expect{ 
        |b| MyMongoid.configure(&b)
      }.to yield_with_args(MyMongoid.configuration)
    end
  end
end

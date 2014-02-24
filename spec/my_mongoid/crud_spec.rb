require "pry"

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

describe "Should be able to get database session:" do
  describe "MyMongoid.session" do
    let(:session) {
      MyMongoid.session
    }

    it "should return a Moped::Session" do
      expect(session).to be_a(Moped::Session)
    end

    it "should memoize the session @session" do
      session2 = MyMongoid.session
      expect(session).to eq(session2)
    end

    context "when host and database is not set" do
      before do
        MyMongoid.configure do |config|
          config.database = nil
          config.host = nil
        end
      end

      after do
        MyMongoid.configure do |config|
          config.database = "my_mongoid"
          config.host = "localhost:27017"
        end
      end

      it "should raise MyMongoid::UnconfiguredDatabaseError if host and database are not configured" do
        expect{
          MyMongoid.session
        }.to raise_error(MyMongoid::UnconfiguredDatabaseError)
      end
  end
  end
end

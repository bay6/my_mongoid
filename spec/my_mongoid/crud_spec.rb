require "active_support/inflector"

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


class Event
  include MyMongoid::Document
end

describe "Should be able to create a record:" do
  describe "model collection:" do
    describe "Model.collection_name" do
      it "should use active support's titleize method" do
        expect(Event.collection.name).to eq(Event.name.tableize)
      end
    end

    describe "Model.collection" do
      it "should return a model's collection" do
        expect(Event.collection).to be_a(Moped::Collection)
      end
    end
  end
end

describe "Should be able to create a record:" do
  let(:attr) {
    {:id => 123}
  }

  let(:event) {
    Event.new(attr)
  }

  describe "#to_document" do
    it "should be a bson document" do
      expect{
        event.to_document.to_bson
      }.not_to raise_error
    end
  end

  describe "Model#save" do
    describe "successful insert:" do
      it "should insert a new record into the db" do
        count = Event.collection.find.to_a.size
        Event.save(event)
        expect(Event.collection.find.to_a.size).to eq(count + 1)
      end

      it "should return true" do
        expect(Event.save(event)).to eq(true)
      end

      it "should make Model#new_record return false" do
        Event.save(event)
        expect(event.new_record?).to eq(false)
      end
    end
  end

  describe "Model.create" do
    it "should return a saved record" do
      event = Event.create(attr)
      expect(event).to be_a(Event)
      expect(event.new_record?).to eq(false)
    end
  end
end

require_relative "../spec_helper"
require_relative "../app/models/event"
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

describe "Should be able to create a record:" do
  describe "model collection:" do
    describe "Model.collection_name" do
      it "should use active support's titleize method" do
        expect(Event.collection_name).to eq(Event.name.tableize)
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
  let(:attrs) {
    {:public => true}
  }

  let(:event) {
    Event.new(attrs)
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
      event = Event.create(attrs)
      expect(event).to be_a(Event)
      expect(event.new_record?).to eq(false)
    end
  end

  describe "saving a record with no id" do
    it "should generate a random id" do
      event = Event.create(attrs)
      expect(event.id).to be_a(BSON::ObjectId)
    end
  end
end

describe "Should be able to find a record:" do
  let(:attrs) {
    {"_id" => "123", "public" => true}
  }

  describe "Model.instantiate" do
    let(:event) {
      Event.instantiate(attrs)
    }

    it "should return a model instance" do
      expect(event).to be_a(Event)
    end

    it "should return an instance that's not a new_record" do
      expect(event.new_record?).to eq(false)
    end

    it "should have the given attributes" do
      expect(event.id).to eq("123")
      expect(event.public).to eq(true)
    end
  end

  describe "Model.find" do
    before do
      event = Event.create(attrs)
    end

    it "should be able to find a record by issuing query" do
      expect(Event.find({"_id" => "123", "public" => true})).to be_a(Event)
    end

    it "should be able to find a record by issuing shorthand id query" do
      expect(Event.find("123")).to be_a(Event)
    end

    it "should raise Mongoid::RecordNotFoundError if nothing is found for an id" do
      expect {
        Event.find("456")
      }.to raise_error(MyMongoid::RecordNotFoundError)
    end
  end
end

describe "Should be able to update a record" do
  describe "#changed_attributes" do
    let(:attrs) {
      {"_id" => "123", "public" => true}
    }

    let(:event) {
      Event.find(attrs)
    }

    before do
      Event.create(attrs)
    end

    it "should be an empty hash initially" do
      expect(event.changed_attributes).to be_empty
    end

    it "should track writes to attributes" do
      event.public = false
      expect(event.changed_attributes.has_key?("public")).to eq(true)
    end

    it "should keep the original attribute values" do
      event.public = false
      expect(event.changed_attributes["public"]).to eq(true)
    end

    it "should not make a field dirty if the assigned value is equaled to the old value" do
      event.public = true
      expect(event.changed_attributes.has_key?("public")).to eq(false)
    end
  end
end

describe "Should track changes made to a record" do
  describe "#changed?" do
    let(:attrs) {
      {"_id" => "123", "public" => true}
    }

    let(:event) {
      Event.find(attrs)
    }

    before do
      Event.create(attrs)
    end

    it "should be false for a newly instantiated record" do
      expect(event).to_not be_changed
    end

    it "should be true if a field changed" do
      event.public = false
      expect(event).to be_changed
    end
  end
end

describe "Should be able to update a record:" do
  let(:attrs) {
    {"_id" => "123", "public" => true}
  }

  let(:event) {
    Event.new(attrs)
  }

  let(:event1) {
    Event.create(attrs)
  }

  let(:event2) {
    Event.find("123")
  }

  describe "#atomic_updates" do
    it "should return {} if nothing changed" do
      event.save
      expect(event.atomic_updates).to be_empty
    end

    it "should return {} if record is not a persisted document" do
      event.public = false
      expect(event.atomic_updates).to be_empty
    end

    it "should generate the $set update operation to update a persisted document" do
      event.save
      event.public = false
      expect(event.atomic_updates).to eq({"$set"=>{"public"=>false}})
    end
  end

  describe "updating database:" do
    describe "#save" do
      it "should have no changes right after persisting" do
        event.public = false
        event.save
        expect(event).to_not be_changed 
      end

      it "should save the changes if a document is already persisted" do
        event.public = false
        event.save
        expect(event2.public).to eq(false)
      end
    end

    describe "#update_document" do
      it "should not issue query if nothing changed" do
        event1.update_document
        expect(event2.attributes).to eq(attrs)
        expect_any_instance_of(Moped::Query).to_not receive(:update)
      end

      it "should update the document in database if there are changes" do
        event1.public = false
        event1.update_document
        expect(event2.public).to eq(false)
      end
    end

    describe "#update_attributes" do
      it "should change and persiste attributes of a record" do
        event1.update_attributes({"public" => false})
        expect(event2.public).to eq(false)
      end
    end    
  end
end

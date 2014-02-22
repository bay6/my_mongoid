require_relative '../spec_helper'
# spec/my_mongoid/document_spec.rb
describe MyMongoid::Document do
  it "is a module" do
    expect(MyMongoid::Document).to be_a(Module)
  end
end

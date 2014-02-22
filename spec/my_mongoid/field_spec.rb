# spec/my_mongoid/field_spec.rb
#require File.expand_path('../spec_helper', __FILE__)
require_relative '../spec_helper'
describe MyMongoid::Field do
  it "is a module" do
    expect(MyMongoid::Field).to be_a(Module)
  end
end

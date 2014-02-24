require_relative "./my_mongoid/version"
require_relative "./my_mongoid/field"
require_relative "./my_mongoid/duplicate_field_error"
require_relative "./my_mongoid/configuration"
require 'active_support/concern'
require 'active_support/core_ext'
require "active_support/inflector"
require 'moped'

module MyMongoid

  module Document
    extend ActiveSupport::Concern

    attr_accessor :new_record

    included do
      ::MyMongoid.register_model(self)
      class_attribute :fields
      self.fields = {}

      field :_id, :as => :id
    end

    def session
      #should be able to read from yaml configuration file
      @session ||= ::Moped::Session.new([ "127.0.0.1:27017" ])
      @session.use 'eacho_test'
    end

    def table_name
      self.class.to_s.downcase
    end

    def initialize attrs = nil
      raise ArgumentError, "A class which includes Mongoid::Document is expected" unless attrs.is_a? Hash
      self.class.fields['_id'] = ::MyMongoid::Field.new '_id'
      self.class.fields['id'] = ::MyMongoid::Field.new 'id'
      @attributes = attrs.with_indifferent_access
      self.attributes = attrs
      @attributes ||= {}
    end

    def attributes
      @attributes
    end

    def read_attribute name
      @attributes.send :[], name
    end
    
    #Create method
    def create params
      session.with(safe: true) do |safe|
        safe[table_name.to_sym].insert( params)
        safe[table_name.to_sym].insert({_id: Time.now.to_i})
        safe[table_name.to_sym].insert({created_at: Time.now})
      end
    end

    def update params
      session.with(safe: true) do |safe|
        safe[table_name.to_sym].update_attributes( params)
        safe[table_name.to_sym].update_attributes(updated_at: Time.now)
      end
    end

    def delete id
      session.with(safe: true) do |safe|
      safe[table_name.to_sym].find(id).remove
      end
    end


    def write_attribute name, value
      @attributes[name] = value
    end

    def process_attributes options={}
      raise MyMongoid::UnknownAttributeError unless options.each_key.all?{|x| self.fields.keys.include? x.to_s}
      options.each_pair do |key, value|
        self.send(key.to_s + '=', value) unless key == 'id'
      end
    end
    alias :attributes= :process_attributes

    def new_record?
      new_record
    end

    def to_document
      attributes
    end

    module ClassMethods
      def field name, as=nil
        raise MyMongoid::DuplicateFieldError, 'duplicate' if self.fields[name.to_s]
        self.fields[name.to_s] = ::MyMongoid::Field.new name, as
        self.instance_eval do
          define_method(name) do 
            value = self.read_attribute name.to_s
            self.class.fields[name.to_s]= MyMongoid::Field.new(name, as)
            value
          end
          alias_method as[:as].to_s, name if as

          define_method((name.to_s + '=').to_sym) do |value|
            self.write_attribute name.to_s, value
          end
          alias_method as[:as].to_s + '=', (name.to_s + '=') if as
        end
      end

      def is_mongoid_model?
        true
      end

      def collection
        MyMongoid.session[self.name.tableize]
      end

      def save(doc)
        collection.insert(doc.to_document)
        doc.new_record = false
        true
      end

      def create(attr = {})
        doc = new(attr)
        save(doc)
        doc
      end
    end
  end

  def self.models
    @models ||= []
  end

  def self.register_model(klass)
    models.push(klass) unless models.include?(klass)
  end

  def self.configuration
    MyMongoid::Configuration.instance
  end

  def self.configure
    block_given? ? yield(self.configuration) : self.configuration
  end

  def self.session
    raise UnconfiguredDatabaseError unless configuration.host
    raise UnconfiguredDatabaseError unless configuration.database
    @session ||= create_session
  end

  def self.create_session
    session ||= ::Moped::Session.new([configuration.host])
    session.use configuration.database
    session
  end


  # Purge all data in all collections, including indexes.
  #
  # Examples
  #   MyMongoid.purge!
  #
  # Returns true when complete.
  def self.purge!
    session.collections.each do |collection|
      collection.drop
    end and true
  end
end

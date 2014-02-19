require_relative "./my_mongoid/version"
require_relative "./my_mongoid/field"
require_relative "./my_mongoid/duplicate_field_error"
require 'active_support/concern'
require 'active_support/core_ext'

module MyMongoid

  module Document
    extend ActiveSupport::Concern

    included do
      ::MyMongoid.register_model(self)
      class_attribute :fields
      self.fields = {}
    end

    def initialize attrs = nil
      raise ArgumentError, "A class which includes Mongoid::Document is expected" unless attrs.is_a? Hash
      self.class.fields['_id'] = ::MyMongoid::Field.new '_id'
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

    def write_attribute name, value
      @attributes[name] = value
    end

    def process_attributes options={}
      raise MyMongoid::UnknownAttributeError unless options.each_key.all?{|x| self.fields.keys.include? x.to_s}
      options.each_pair do |key, value|
        self.send(key.to_s + '=', value)
      end
    end
    alias :attributes= :process_attributes

    def new_record?
      true
    end

    module ClassMethods
      def field name, as=nil
        raise MyMongoid::DuplicateFieldError, 'duplicate' if self.fields[name.to_s]
        self.fields[name.to_s] = ::MyMongoid::Field.new name, as
        self.instance_eval do
          define_method(name) do 
            value = self.read_attribute name.to_s
            self.class.fields[name.to_s]= value
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

    end
  end

  def self.models
    @models ||= []
  end

  def self.register_model(klass)
    models.push(klass) unless models.include?(klass)
  end
end

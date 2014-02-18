require_relative "./my_mongoid/version"
require_relative "./my_mongoid/field"
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
      @attributes = attrs
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

    def new_record?
      true
    end

    module ClassMethods
      def field name
        self.fields[name.to_s] = ::MyMongoid::Field.new name
        self.instance_eval do
          define_method(name) do 
            value = self.read_attribute name.to_s
            self.class.fields[name.to_s]= value
            value
          end

          define_method((name.to_s + '=').to_sym) do |value|
            self.write_attribute name.to_s, value
          end
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

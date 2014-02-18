require_relative "./my_mongoid/version"
require 'active_support/concern'

module MyMongoid

  module Document
    extend ActiveSupport::Concern

    included do
      ::MyMongoid.register_model(self)
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

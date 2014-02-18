require_relative "./my_mongoid/version"
require 'active_support/concern'

module MyMongoid

  module Document
    extend ActiveSupport::Concern

    included do
      ::MyMongoid.register_model(self)
    end

    module ClassMethods
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

require_relative "./my_mongoid/version"
require 'active_support/concern'

module MyMongoid
  module Document
    extend ActiveSupport::Concern
    module ClassMethods
      def is_mongoid_model?
        true
      end
    end
  end
end

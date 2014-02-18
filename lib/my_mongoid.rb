require_relative "./my_mongoid/version"

module MyMongoid
  module Document
    module ClassMethods
      def is_mongoid_model?
        true
      end
    end
  end
end

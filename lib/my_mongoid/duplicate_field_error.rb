module MyMongoid
  class DuplicateFieldError < ArgumentError

  end
  
  class UnknownAttributeError < ArgumentError
  end

  class UnconfiguredDatabaseError < ArgumentError
  end

  class RecordNotFoundError < StandardError
  end
end

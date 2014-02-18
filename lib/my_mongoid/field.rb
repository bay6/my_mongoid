module MyMongoid
  class Field
    def initialize name
      @name ||= name
    end

    def name
      @name.to_s
    end
  end
end

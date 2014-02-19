module MyMongoid
  class Field
    def initialize name, as=nil
      @name ||= name
      @options ||= as
    end

    def name
      @name.to_s
    end

    def options
      @options
    end
  end
end

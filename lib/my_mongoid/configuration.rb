require 'singleton'
module MyMongoid

  def self.configuration
    @configuration ||= MyMongoid::Configuration.instance
  end

  def self.configure
    block_given? ? yield(self.configuration) : self.configuration
  end

  class Configuration
    include Singleton
    def host
      @host

    end

    def host= host
      @host = host
    end

    def database
      @database
    end

    def database= database
      @database = database
    end
  end
end


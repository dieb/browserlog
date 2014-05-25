require 'singleton'

module Browserlog
  class Config
    include Singleton

    attr_accessor :allow_production_logs

    def initialize
      @allow_production_logs = false
    end
  end
end

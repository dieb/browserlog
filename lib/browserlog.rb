require 'browserlog/engine'

module Browserlog
  autoload :LogReader, 'browserlog/log_reader'
  autoload :LogColorize, 'browserlog/log_colorize'
  autoload :SelectiveLogger, 'browserlog/selective_logger'
  autoload :Config, 'browserlog/config'

  def self.config
    Config.instance
  end
end

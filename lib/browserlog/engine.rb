module Browserlog
  class Engine < ::Rails::Engine
    isolate_namespace Browserlog

    config.generators do |g|
      g.test_framework :rspec, fixture: false
      g.assets false
      g.helper false
    end

    initializer 'browserlog.swap_logger' do |app|
      app.middleware.swap Rails::Rack::Logger, SelectiveLogger
    end

    def call(env)
      case Rails.version
      when /\A3/
        if SKIP_PATHS.any? { |path| env['PATH_INFO'].include?(path) } ||
          env['SCRIPT_NAME'] =~ /logs/
          silence { super }
        else
          super
        end
      when /\A4/
        Rails.logger.silence { super }
      end
    end

    def silence(&block)
      prev = Rails.logger.level
      Rails.logger.level = 4
      ret = block.call
      Rails.logger.level = prev
      ret
    end
  end
end

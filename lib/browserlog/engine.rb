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
        if SKIP_PATHS.any? { |path| env['PATH_INFO'].include?(path) } or env['SCRIPT_NAME'] =~ /logs/
          prev = Rails.logger.level
          Rails.logger.level = 4
          ret = super
          Rails.logger.level = prev
          ret
        else
          super
        end
      when /\A4/
        Rails.logger.silence do
          super
        end
      end
    end
  end
end

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
      Rails.logger.silence do
        super
      end
    end
  end
end

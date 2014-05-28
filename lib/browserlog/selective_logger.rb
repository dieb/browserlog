module Browserlog
  SKIP_PATHS = %w(/changes.json /browserlog/ jquery /logs/).freeze

  module SelectiveLogger3
    def call_app(request, env)
      if SKIP_PATHS.any? { |path| env['PATH_INFO'].include?(path) }
        @app.call(env)
      else
        # Put some space between requests in development logs.
        if Rails.env.development?
          Rails.logger.info ''
          Rails.logger.info ''
        end

        Rails.logger.info started_request_message(request)
        @app.call(env)
      end
    ensure
      ActiveSupport::LogSubscriber.flush_all!
    end
  end

  module SelectiveLogger4
    def call_app(request, env)
      # Put some space between requests in development logs.
      if SKIP_PATHS.any? { |path| env['PATH_INFO'].include?(path) }
        @app.call(env)
      else
        default_behaviour(request, env)
      end
    rescue Exception
      finish(request)
      raise
    ensure
      ActiveSupport::LogSubscriber.flush_all!
    end

    private

    def default_behaviour(request, env)
      if development?
        logger.debug ''
        logger.debug ''
      end

      instrumenter = ActiveSupport::Notifications.instrumenter
      instrumenter.start 'request.action_dispatch', request: request
      logger.info started_request_message(request)
      resp = @app.call(env)
      resp[2] = ::Rack::BodyProxy.new(resp[2]) { finish(request) }
      resp
    end
  end

  class SelectiveLogger < Rails::Rack::Logger
    case Rails.version
    when /\A3/
      include SelectiveLogger3
    when /\A4/
      include SelectiveLogger4
    end
  end
end

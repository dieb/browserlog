module Browserlog
  class SelectiveLogger < Rails::Rack::Logger
    SKIP_PATHS = %w(/changes.json /browserlog/ jquery /logs/).freeze

    protected

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
end

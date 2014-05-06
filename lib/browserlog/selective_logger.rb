class SelectiveLogger < Rails::Rack::Logger
  protected

  def call_app(request, env)
    # Put some space between requests in development logs.
    unless ['/changes.json', '/browserlog/'].any? { |path| env['PATH_INFO'].include?(path) }
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
    else
      @app.call(env)
    end
  rescue Exception
    finish(request)
    raise
  ensure
    ActiveSupport::LogSubscriber.flush_all!
  end

end
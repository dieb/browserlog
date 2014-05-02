require_dependency 'browserlog/browserlog/application_controller'

module Browserlog
  class LogsController < ApplicationController
    INTERVAL = 5.seconds

    include ActionController::Live

    before_filter :set_starting_point, only: :changes

    def index
    end

    def changes
      response.headers['Content-Type'] = 'text/event-stream'
      running = true
      at_exit { running = false }
      while running
        changes = @differ.latest_changes
        response.stream.write JSON.dump(changes) if changes.size > 0
        sleep INTERVAL
      end
    ensure
      response.stream.close
    end

    private

    def set_starting_point
      @differ = Browserlog::Logdiff.new(
        file: Rails.root.join("log/#{Rails.env}.log"),
        buffer_size: INTERVAL * 100
      )
    end
  end
end

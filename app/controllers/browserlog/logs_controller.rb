module Browserlog
  class LogsController < ApplicationController
    before_filter :check_env

    def index
      @filename = "#{params[:env]}.log"
      @filepath = Rails.root.join("log/#{@filename}")
    end

    def changes
      reader = Browserlog::LogReader.new
      lines, last_line_number = reader.read(offset: params[:currentLine].to_i)

      respond_to do |format|
        format.json do
          render json: {
            lines: lines,
            last_line_number: last_line_number
          }
        end
      end
    end

    private

    def check_env
      fail unless %w(test development production).include?(params[:env])
    end
  end
end

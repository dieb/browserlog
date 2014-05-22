module Browserlog
  class LogsController < ApplicationController
    before_filter :check_env
    layout 'browserlog/application'

    def index
      @filename = "#{params[:env]}.log"
      @filepath = Rails.root.join("log/#{@filename}")
    end

    def changes
      lines, last_line_number = reader.read(offset: params[:currentLine].to_i)

      respond_to do |format|
        format.json do
          render json: {
            lines: lines.map! { |line| colorizer.colorize_line(line) } ,
            last_line_number: last_line_number
          }
        end
      end
    end

    private

    def reader
      Browserlog::LogReader.new
    end

    def colorizer
      Browserlog::LogColorize.new
    end

    def check_env
      fail unless %w(test development production).include?(params[:env])
    end
  end
end

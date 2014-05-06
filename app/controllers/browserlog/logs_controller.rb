module Browserlog
  class LogsController < ApplicationController
    def index
      raise unless ['test', 'development', 'production'].include?(params[:env])
      @filename = "#{params[:env]}.log"
      @filepath = Rails.root.join("log/#{@filename}")
    end

    def changes
      raise unless ['test', 'development', 'production'].include?(params[:env])
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
  end
end

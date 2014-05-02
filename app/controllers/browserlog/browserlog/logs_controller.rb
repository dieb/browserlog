require_dependency "browserlog/browserlog/application_controller"

module Browserlog
  class Browserlog::LogsController < ApplicationController
    INTERVAL = 5.seconds
    BUFFER_SIZE = INTERVAL * 100
    MAX_LOOKUPS = 10

    include ActionController::Live

    before_filter :set_starting_point, only: :changes

    def index
    end

    def changes
      response.headers['Content-Type'] = 'text/event-stream'
      
      running = true

      at_exit do
        puts "Exiting changes loop"
        running = false
      end

      while running
        changes = compute_changes
        response.stream.write JSON.dump(changes) if changes.size > 0
        sleep INTERVAL
      end

    ensure
      response.stream.close
    end

    private

    def compute_changes
      return read_final_bits unless @last_seen

      chunks = []
      MAX_LOOKUPS.times do |current_offset|
        chunks.unshift read_chunk(current_offset)
        break if chunks.first.include?(@last_seen)
      end

      found = chunks.first.include?(@last_seen)

      if found
        next_line = chunks.first.index(@last_seen) + 1
        first_remaining = chunks.first[next_line..-1]
        result = (first_remaining + chunks[1..-1]).flatten
        @last_seen = result[-1]
        result
      else
        []
      end
    end

    def read_chunk buffers_from_bottom=0
      offset_from_bottom = buffers_from_bottom * BUFFER_SIZE
      remaining_size = @log_filesize - offset_from_bottom
      return [] if remaining_size < 0

      amount = [remaining_size, BUFFER_SIZE].min
      seekpos = remaining_size - BUFFER_SIZE
      seekpos = 0 if seekpos < 0

      with_seek seekpos do
        @log_file.read(amount).split(/\n/)
      end
    end

    def with_seek position, &block
      @log_file.seek(position)
      retval = block.call
      @log_file.seek(0)
      retval
    end

    def read_final_bits
      chunk = read_chunk
      @last_seen = chunk[-1] if chunk.size > 0
      chunk
    end

    def set_starting_point
      log_filename = Rails.root.join("log/#{Rails.env}.log")
      @log_file = File.new(log_filename)
      @log_filesize = @log_file.size
      @last_seen = nil
    end
  end
end

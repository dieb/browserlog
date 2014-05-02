module Browserlog
  class Logdiff
    MAX_LOOKUPS = 10

    def initialize log_filename, buffer_size
      @buffer_size = buffer_size
      @log_filename = log_filename
      @log_file = File.new(log_filename)
      @last_seen = nil
    end

    def latest_changes
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
      offset_from_bottom = buffers_from_bottom * @buffer_size
      remaining_size = @log_file.size - offset_from_bottom
      return [] if remaining_size < 0

      amount = [remaining_size, @buffer_size].min
      seekpos = remaining_size - @buffer_size
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
  end
end

module Browserlog
  class Logdiff
    MAX_LOOKUPS = 10

    def initialize options = {}
      @buffer_size = options[:buffer_size]
      @log_filename = options[:file]
      @last_seen = nil

      raise "No such file or directory #{options[:file]}" unless File.exists? @log_filename
      raise "Invalid buffer size (must be > 0)" unless @buffer_size > 0

      @log_file = File.new(@log_filename)
    end

    def latest_changes
      return final_chunk unless @last_seen

      chunks = []
      MAX_LOOKUPS.times do |current_offset|
        chunks.unshift read_chunk(current_offset)
        break if chunks.first.include?(@last_seen)
      end

      found = chunks.first.include?(@last_seen)

      if found
        unseen_logs(chunks)
      else
        []
      end
    end

    def unseen_logs chunks
      last_seen_line_index = chunks.first.index(@last_seen)
      unseen_logs_from_first_chunk = chunks.first[last_seen_line_index + 1..-1]
      all_unseen = (unseen_logs_from_first_chunk + chunks[1..-1]).flatten
      @last_seen = all_unseen[-1]
      all_unseen
    end

    def read_chunk buffers_from_bottom=0
      offset_from_bottom = buffers_from_bottom * @buffer_size
      remaining_size = @log_file.size - offset_from_bottom
      return [] if remaining_size < 0

      amount = [remaining_size, @buffer_size].min
      offset = remaining_size > @buffer_size ? remaining_size - @buffer_size : 0

      log_readlines offset, amount
    end

    def log_readlines offset, amount
      with_seek offset do
        @log_file.read(amount).split(/\n/)
      end
    end

    def with_seek position, &block
      @log_file.seek(position)
      retval = block.call
      @log_file.seek(0)
      retval
    end

    def final_chunk
      chunk = read_chunk
      @last_seen = chunk[-1] if chunk.size > 0
      chunk
    end
  end
end

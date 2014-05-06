module Browserlog
  class LogReader
    def read options = {}
      offset = options[:offset] || -1
      limit = options[:limit] || 25
      amount = [limit, remaining_lines(offset)].min

      if offset == -1
        line_index = num_lines
        [readlines(amount), line_index]
      else
        line_index = offset + amount
        [readlines(amount), line_index]
      end
    end

    private

    def remaining_lines(offset)
      (offset == -1) ? num_lines : (num_lines - offset)
    end

    def num_lines
      `wc -l #{log_path}`.split.first.to_i
    end

    def log_path
      Rails.root.join("log/#{Rails.env}.log")
    end

    def file
      @file ||= File.new log_path
    end

    def readlines(amount)
      `tail -n #{amount} #{log_path}`.split(/\n/)
    end

    def with_seek(position, &block)
      puts "Seeking to #{position}"
      file.seek(position)
      retval = block.call
      file.seek(0)
      retval
    end
  end
end
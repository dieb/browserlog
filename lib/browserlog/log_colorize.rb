module Browserlog
  class LogColorize
    REXP_REQUEST =    /^Started (?<method>\w+) "(?<path>[\w\/\?\&\=\.]+)" for (?<ip>[\d\.]+) at (?<date>[\w:\-\s]+)$/
    REXP_CONTROLLER = /^Processing by (?<controller>[\w\:]+)#(?<action>\w+) as (?<format>\w+)$/
    REXP_RENDER =     /^\s+Rendered (?<path>[\w\.\-\/]+\/)(?<template_name>\w+\.html\.\w+) \((?<rendering_time>[\d+\.]+ms)\)$/
    REXP_COMPLETE =   /^Completed (?<status>\d+\s\w+) in (?<total_time>[\d+\.]+ms) (?<last_bit>.*)$/

    def colorize_line(line)
      case line
      when REXP_REQUEST then colorize_request(line)
      when REXP_CONTROLLER then colorize_controller(line)
      when REXP_RENDER then colorize_render(line)
      when REXP_COMPLETE then colorize_complete(line)
      else line
      end
    rescue => e
      puts "Could not colorize: #{e.message}"
      line
    end

    private

    def bold(item)
      "<span style='font-weight: bold'>#{item}</span>"
    end

    def color(item, color)
      "<span style='color: #{color}'>#{item}</span>"
    end

    def colorize_request(line)
      data = regex_parse(line.match(REXP_REQUEST))
      method = color(data[:method], '#999')
      path = color(data[:path], 'green')
      ip = color(data[:ip], '#888')
      date = color(data[:date], '#777')
      "Started #{method} \"#{path}\" for #{ip} at #{date}"
    end

    def colorize_controller(line)
      data = regex_parse(line.match(REXP_CONTROLLER))
      controller = color(data[:controller], 'magenta')
      action = color(data[:action], 'magenta')
      format = color(data[:format], '#aaa')
      "Processing by #{controller}##{action} as #{format}"
    end

    def colorize_render(line)
      data = regex_parse(line.match(REXP_RENDER))
      path = data[:path]
      template_name = color(data[:template_name], '#aaa')
      rendering_time = color(data[:rendering_time], '#aaa')
      "Rendered #{path}#{template_name} (#{rendering_time})"
    end

    def colorize_complete(line)
      data = regex_parse(line.match(REXP_COMPLETE))
      status = color(data[:status], data[:status] =~ /^2/ ? 'green' : 'red')
      total_time = color(data[:total_time], '#888')
      "Completed #{status} in #{total_time} #{data[:last_bit]}"
    end

    def regex_parse(match)
      Hash[match.names.collect { |k| k.to_sym }.zip(match.captures)]
    end
  end
end

module Browserlog
  class LogColorize
    REXP_REQUEST    = /^Started (?<method>\w+) "(?<path>[\w\/\?\&\=\.]+)" for (?<ip>[\d\.]+) at (?<date>[\w:\-\+\s]+)$/
    REXP_CONTROLLER = /^Processing by (?<controller>[\w\:]+)#(?<action>\w+) as (?<format>\[\w\/\-\.]+)$/
    REXP_RENDER     = /^\s*Rendered (?<path>.*\/)(?<template_name>\w+\.html\.\w+) \((?<rendering_time>[\d+\.]+ms)\)$/
    REXP_RENDER_WITHIN = /^\s*Rendered (?<path>.*\/)(?<template_name>\w+\.html\.\w+) within (?<layout_name>[\w\d\/]+) ?\((?<rendering_time>[\d+\.]+ms)\)$/
    REXP_COMPLETE   = /^Completed (?<status>\d+\s\w+) in (?<total_time>[\d+\.]+ms) (?<last_bit>.*)$/
    REXP_SQL_QUERY  = /^\s*(?<model_load>[\w:]+ Load) \((?<rendering_time>[\d+\.]+ms)\) \s*(?<sql_query>.*)$/

    def colorize_line(line)
      line = strip_ansi_colors(line)
      line = colorize(line)
    rescue => e
      puts "Could not colorize: #{e.message}"
      line
    end

    private

    def strip_ansi_colors(line)
      line.gsub(/\e\[(\d+)m/, '')
    end

    def colorize(line)
      case line
      when REXP_REQUEST       then colorize_request(line)
      when REXP_CONTROLLER    then colorize_controller(line)
      when REXP_RENDER        then colorize_render(line)
      when REXP_RENDER_WITHIN then colorize_render_within(line)
      when REXP_COMPLETE      then colorize_complete(line)
      when REXP_SQL_QUERY     then colorize_sql_query(line)
      else line
      end
    end

    def span(item, classname)
      "<span class='#{classname}'>#{item}</span>"
    end

    def space
      '&nbsp;&nbsp;'
    end

    def colorize_request(line)
      data = regex_parse(line.match(REXP_REQUEST))
      method = span(data[:method], 'method')
      path = span(data[:path], 'path')
      ip = span(data[:ip], 'ip')
      date = span(data[:date], 'date')
      "Started #{method} \"#{path}\" for #{ip} at #{date}"
    end

    def colorize_controller(line)
      data = regex_parse(line.match(REXP_CONTROLLER))
      controller = span(data[:controller], 'controller')
      action = span(data[:action], 'action')
      format = span(data[:format], 'format')
      "Processing by #{controller}##{action} as #{format}"
    end

    def colorize_render(line)
      data = regex_parse(line.match(REXP_RENDER))
      path = data[:path]
      template_name = span(data[:template_name], 'template-name')
      rendering_time = span(data[:rendering_time], 'rendering-time')
      "#{space}Rendered #{path}#{template_name} (#{rendering_time})"
    end

    def colorize_render_within(line)
      data = regex_parse(line.match(REXP_RENDER_WITHIN))
      path = data[:path]
      layout_name = span(data[:layout_name], 'layout-name')
      template_name = span(data[:template_name], 'template-name')
      rendering_time = span(data[:rendering_time], 'rendering-time')
      "#{space}Rendered #{path}#{template_name} within #{layout_name} (#{rendering_time})"
    end

    def colorize_sql_query(line)
      data = regex_parse(line.match(REXP_SQL_QUERY))
      model_load = span(data[:model_load], 'model-load')
      rendering_time = span(data[:rendering_time], 'rendering-time')
      sql_query = data[:sql_query]
      "#{space}#{model_load} (#{rendering_time}) #{sql_query}"
    end

    def colorize_complete(line)
      data = regex_parse(line.match(REXP_COMPLETE))
      status = span(data[:status], data[:status] =~ /^2/ ? 'status success' : 'status failure')
      total_time = span(data[:total_time], 'total-time')
      "Completed #{status} in #{total_time} #{data[:last_bit]}"
    end

    def regex_parse(match)
      Hash[match.names.collect { |k| k.to_sym }.zip(match.captures)]
    end
  end
end

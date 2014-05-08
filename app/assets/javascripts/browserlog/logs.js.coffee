class ThemeSwitcherView
  constructor: ->
    @body = $('body')
    $(document).on('change', '.theme-switch', @switchTheme)
    @loadTheme()

  switchTheme: (e) =>
    localStorage.setItem('browserlog-theme', e.target.value)
    @loadTheme()

  loadTheme: ->
    $('.theme-switch').val(@getCurrentTheme())
    @body.attr('data-theme', @getCurrentTheme())

  getCurrentTheme: ->
    localStorage.getItem('browserlog-theme') || 'dark'

class LogView

  constructor: ->
    @lines = $('#lines')
    @body = $('body')
    @resumeButton = $('.resume-scroll-btn')
    @autoScroll = true
    @attachEvents()

  attachEvents: ->
    window.onscroll = @disableAutoScroll
    @body.on('click', '.resume-scroll-btn', @enableAutoScroll)

  update: (lines) ->
    @appendLines(lines)
    @updateScroll() if @autoScroll

  appendLines: (lines) ->
    linesString = ''
    linesString += "<li>#{line}</li>" for line in lines
    @lines.append(linesString)

  disableAutoScroll: (e) =>
    if (e.timeStamp > @timestamp) and @hasScroll() and @body.scrollTop() > 0
      @autoScroll = false
      @resumeButton.removeClass('hidden')

  enableAutoScroll: =>
    @autoScroll = true
    @resumeButton.addClass('hidden')
    @updateScroll()

  updateScroll: ->
    @body.scrollTop(@body.prop('scrollHeight'))
    @timestamp = (new Date()).getTime()

  hasScroll: ->
    @body.height() == @body.prop('scrollHeight')


class LogFeed
  POLL_PERIOD: 1500

  constructor: (listener) ->
    @listener = listener
    @currentLine = -1

  getLines: =>
    $.get(window.location.href + '/changes.json', {currentLine: @currentLine})
    .done(@getLinesSuccess)
    .fail(@getLinesError)
    .always(@getLinesComplete)

  getLinesSuccess: (data, status, xhr) =>
    @listener.update(data.lines)
    @currentLine = data.last_line_number

  getLinesError: (data, status, err) =>
    console.log "Error fetching logs"
    # TODO

  getLinesComplete: (xhr, status) =>
    @reschedule()

  start: ->
    setTimeout @getLines, 0

  reschedule: ->
    setTimeout @getLines, @POLL_PERIOD

$ ->
  logfeed = new LogFeed(new LogView)
  logfeed.start()

  new ThemeSwitcherView

  console.log "Started fetching logs"

class LogFeed
  POLL_PERIOD: 500

  constructor: ->
    @currentLine = -1
    @lines = $('#lines')

  getLines: =>
    $.get(window.location.href + '/changes.json',
      {currentLine: @currentLine},
      this.getLinesSuccess
    )
    .fail(this.getLinesError)
    .always(this.getLinesComplete)

  getLinesSuccess: (data, status, xhr) =>
    this.displayLines data.lines
    @currentLine = data.last_line_number

  getLinesError: (data, status, err) =>
    console.log "Error fetching logs"
    # TODO

  getLinesComplete: (xhr, status) =>
    this.reschedule()

  displayLines: (lines) ->
    this.appendLine(line) for line in lines
    @lines.scrollTop @lines.prop('scrollHeight')

  appendLine: (line) ->
    $("<li>#{line}</li>").appendTo @lines

  start: ->
    setTimeout this.getLines, 0

  reschedule: ->
    setTimeout this.getLines, @POLL_PERIOD

onReady = -> 
  logfeed = new LogFeed
  logfeed.start()

  console.log "Started fetching logs"

$(document).ready onReady
$(document).on 'page:load', onReady
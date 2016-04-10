# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

class window.TextBox
  constructor: (@box, @cursorPlacer, @fontSizeManager) ->
    @chars = []

  addChar: (char) ->
    @chars.push char
    @_draw()

  deleteChar: ->
    @chars.pop()
    @_draw()

  _draw: ->
    @box.html CharWrapperNoSpans.wrap(@chars)
    @cursorPlacer.placeCursorAtEnd()
    @fontSizeManager.adjustFont()

class window.CharWrapper
  @wrap: (charArray) ->
    @_wrapChar(code, i) for code, i in charArray

  @_wrapChar: (code,i) ->
    span = if code is 13 then '<br/>' else ''
    span += "<span>#{@_charWithCode code}</span>"
    @_styleSpan $(span), i

  @_charWithCode: (code) ->
    switch code
      when 32 then '&nbsp'
      when 13 then ''
      else String.fromCharCode code

  @_styleSpan: (el, i) ->
    style = float: "left"
    $(el).last().css(style).attr('class', 'Char').data('index', i)
    $(el)

class window.CharWrapperNoSpans
  @wrap: (charArray) ->
    (@_charWithCode(code) for code in charArray).join('') + @_cursor()

  @_charWithCode: (code) ->
    switch code
      when 13 then '<br/>'
      else String.fromCharCode code

  @_cursor: ->
    "<span class='Char End'/>"


class window.CursorPlacer
  constructor: (@box) ->

  placeCursor: (position) ->
    @_styleCursor $(@box).find('.Char')[position]

  placeCursorAtEnd: ->
    @placeCursor @_lastPosition()

  _lastPosition: ->
    $(@box).find('.Char').size() - 1

  _styleCursor: (el) ->
    $(el).addClass('Cursor')

class window.KeyObserver
  constructor: (@delegate) ->
    @addObservers()

  addObservers: =>
    $(document).keydown @_onKeyDown
    $(document).keypress @_onKeyPress

  _onKeyPress: (e) =>
    @delegate.addChar e.charCode

  _onKeyDown: (e) =>
    if e.keyCode is 8
      e.preventDefault()
      @delegate.deleteChar()

class window.FontSizeManager
  constructor: (@box) ->
    @fontSize = 24
    @_setFontSize()

  adjustFont: ->
    while @_onBottomLine()
      @fontSize -= 1
      @_setFontSize()

  _onBottomLine: ->
    console.log "boxBottom: #{@_boxBottom()} textBottom: #{@_textBottom()}"
    @_textBottom() > @_boxBottom() - @fontSize / 2

  _boxBottom: ->
    @box.offset().top + @box.height() + parseInt @box.css('padding-top') + parseInt @box.css('padding-bottom')

  _textBottom: ->
    @box.find('.End').offset().top + @fontSize

  _setFontSize: ->
    style =
      'font-size': "#{@fontSize}px"
    @box.css style


class window.WireFrame
  constructor: ->
    @_makeWireFrame()

  _makeWireFrame: =>
    @textBoxEl = $('#TextBox1')
    @cursorPlacer = new CursorPlacer @textBoxEl
    @fontSizeManager = new FontSizeManager @textBoxEl
    @textBox = new TextBox @textBoxEl, @cursorPlacer, @fontSizeManager
    @keyObserver = new KeyObserver @textBox

$(document).ready =>
  @wf = new WireFrame

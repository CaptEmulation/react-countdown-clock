React  = require 'react'


easeOutQuad = (currentTime, start, end, duration) ->
	currentTime /= duration
	-end * currentTime * ( currentTime-2 ) + start

module.exports = React.createClass
  _currentPercentage: 0
  _radius: null
  _fraction: null
  _content: null
  _canvas: null
  
  mixins: [require './onAppearMixin']
  
  propTypes:
    transitionMs: React.PropTypes.number
    targetPercentage: React.PropTypes.number
    currentPercentage: React.PropTypes.number
    size: React.PropTypes.number
    color: React.PropTypes.string
    alpha: React.PropTypes.number
    animated: React.PropTypes.bool
    onComplete: React.PropTypes.func
    onProgress: React.PropTypes.func    

  getDefaultProps: ->
    size: 300
    color: '#000'
    alpha: 1
    currentPercentage: 0
    
  componentWillUnmount: ->
    @_unmountables.forEach (u) -> u()
      
  componentWillMount: ->
    @_unmountables = [];
    @_seconds = @props.transitionMs
    @_currentPercentage = @props.currentPercentage || 0;
    
  componentWillReceiveProps: (props) ->
    if @_currentPercentage == @props.targetPercentage && @_currentPercentage != @props.currentPercentage
      @_updated = false
      @_seconds = @props.transitionMs  
      @_currentPercentage = @props.currentPercentage || 0
      @_setupTimer();
      

  componentDidMount: ->
    @_setScale()
    @_setupCanvas()
    @_drawTimer()
    @_drawBackground()
    
    if (@isVisible React.findDOMNode(@))
      @setState({ visible: true })
      @_setupTimer() 
    
    @_unmountables.push( 
      @onAppearHandler( 
        React.findDOMNode(@) 
        -> 
          if not @_animateing
             @_setupTimer() 
        -> @setState({ visible: false }) 
        @
      )
    )

  _setupTimer: ->
    @_animateing = true
    @_startTimer()

  _updateCanvas: ->
    @_clearTimer()
    @_drawTimer()

  _setScale: ->
    @_delta      = Math.abs @_currentPercentage - @props.targetPercentage;
    @_charge     = @_currentPercentage < @props.targetPercentage
    @_radius     = @props.size / 2
    @_tickPeriod = 20;

  _setupCanvas: ->
    @_canvas  = @getDOMNode()
    @_context = @_canvas.getContext '2d'
    @_context.textAlign = 'center'
    @_context.textBaseline = 'middle'
    @_context.font = "bold #{@_radius/2}px Arial"

  _startTimer: ->
    # Give it a moment to collect it's thoughts for smoother render
    setTimeout ( => @_tick() ), 0

  _tick: ->
    start = Date.now()
    @_updated = false;
    @_timerId = setTimeout ( =>
      duration = Date.now() - start
      @_seconds -= duration
      @_currentPercentage = easeOutQuad @props.transitionMs -  @_seconds, @props.currentPercentage, @props.targetPercentage, @props.transitionMs
      # @_currentPercentage += @_charge * duration * @_delta / @props.transitionMs

      if @_seconds <= 0
        @_currentPercentage = @props.targetPercentage
        @_updateCanvas()
        @_handleComplete()
      else
        @_updateCanvas()
        @_tick()
    ), @_tickPeriod

  _handleComplete: ->
    @_animateing = false
    if @props.onComplete
      @props.onComplete()

  _clearTimer: ->
    clearTimeout @_timerId
    @_context.clearRect 0, 0, @_canvas.width, @_canvas.height
    @_drawBackground()

  _drawBackground: ->
    @_context.beginPath()
    @_context.globalAlpha = @props.alpha / 3
    @_context.arc @_radius, @_radius, @_radius,     0,           Math.PI * 2, false
    @_context.arc @_radius, @_radius, @_radius/1.8, Math.PI * 2, 0,           true
    @_context.fill()

  _drawTimer: ->
    @_updated = true;
    radians = @_currentPercentage / 100 * (Math.PI * 2) - Math.PI/2
    @_context.globalAlpha = @props.alpha
    @_context.fillStyle = @props.color
    @_context.font = "35px bebas";
    @_context.fillText (@_currentPercentage).toFixed(0) + '%', @_radius, @_radius
    @props.onProgress && @props.onProgress @_currentPercentage
    @_context.beginPath()
    @_context.arc @_radius, @_radius, @_radius,     -Math.PI/2,     radians, false
    @_context.arc @_radius, @_radius, @_radius/1.8, radians, -Math.PI/2,     true
    @_context.fill()

  render: ->
    <canvas className="react-countdown-clock" width={@props.size} height={@props.size}></canvas>

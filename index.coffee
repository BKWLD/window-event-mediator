###
Mediator pattern for window event listeners

Example Usage:
	mediator = require 'window-event-mediator'
	mediator.on 'resize', myCallback
	mediator.off 'scroll', mycallback
###
_ = require 'lodash'

class WindowEventMediator
	constructor: -> return

	# Stores a record on all event listener types, subscribed callbacks, and
	# Throttle/Debounce option keys
	handlers: {}

	# Default options
	defaults:
		throttle: 100
		debounce: 0

	###
	Register an event handler with the mediator

	event - string - event name ('resize', 'scroll', etc)
	callback - function
	options
		throttle [100] - int - milliseconds to throttle
		debounce [100] - int - milliseconds to debounce
	###
	on: (event, callback, options) =>
		options = _.merge {}, @defaults, options
		@set event, callback, options

	###
	Removes any reference to the event type and callback, regardless of
	Throttle or Debounce options.

	event - string - event name ('resize', 'scroll', etc)
	callback - function
	###
	off: (event, callback) =>
		_.pull @handlers[event].callbacks, callback

	###
	Create an event container for the window event type and
	add the actual listener to the window object

	event - string - event name ('resize', 'scroll', etc)
	###
	set: (event, callback, options) =>
		key = options.throttle+'-'+options.debounce

		# If the event type hasn't been added, create an object to store the callbacks
		# and a record of which throttle.debounce listeners have been added
		if !@handlers[event]?
			@handlers[event] = {callbacks: [], keys: {}}

		# Only add the window listener if it doesn't exist
		if !@handlers[event].keys[key]?
			@handlers[event].keys[key] = true
			window.addEventListener event,
				_.debounce(_.throttle(@fire, options.throttle), options.debounce)

		# Save the callback references
		@handlers[event].callbacks.push callback

	###
	Fires all events for a given window event type,
	padding the native event object through to the mediated callback

	e - Event - native event object
	###
	fire: (e) =>
		events = @handlers[e.type]
		event(e) for event in events.callbacks

module.exports = new WindowEventMediator()

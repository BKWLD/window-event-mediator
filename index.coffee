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

	event - string - event name ('resize', 'scroll', etc) callback - function
	options
		throttle [100] - int - milliseconds to throttle
		debounce [100] - int - milliseconds to debounce
	###
	on: (event, callback, options) =>
		options = _.merge {}, @defaults, options
		@set event, callback, options

	###
	Removes any reference to the event type and callback, regardless of Throttle
	or Debounce options.

	event - string - event name ('resize', 'scroll', etc)
	callback - function
	options - target specific throttled/debounced refrences to remove.
	###
	off: (event, callback, options) =>
		return if not @handlers[event]?
		if options?
			options = _.merge {}, @defaults, options
			key = options.throttle+'-'+options.debounce
			if @handlers[event][key]?
				_.remove @handlers[event][key], (cbs) -> return (cbs.original == callback)
		else
			_.each @handlers[event], (arr) ->
				_.remove arr, (cbs) -> return (cbs.original == callback)

	###
	Create an event container for the window event type and
	add the actual listener to the window object

	event - string - event name ('resize', 'scroll', etc)
	###
	set: (event, callback, options) =>
		key = options.throttle+'-'+options.debounce

		# If the event type hasn't been added, create an object to store the
		# callbacks and a record of which throttle.debounce listeners have been
		# added
		@handlers[event] = {} if !@handlers[event]?

		# Only add the window listener if it doesn't exist
		if !@handlers[event].hasOwnProperty(key)
			@handlers[event][key] = []
			window.addEventListener event, @fire

		# Save the callback references, including the original event for removing later
		@handlers[event][key].push
			modified: _.debounce(_.throttle(callback))
			original: callback

	###
	Fires all events for a given window event type, padding the native event
	object through to the mediated callback. It must be looped through backwards
	so that callbacks which are removed during the loop don't break the
	iteration.

	e - Event - native event object
	###
	fire: (e) =>
		_.forEachRight @handlers[e.type], (bag) ->
			_.each bag, (cbs) -> cbs.modified(e); return true

# This operates as a singleton
module.exports = new WindowEventMediator()

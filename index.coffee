###
Mediator pattern for window event listeners

Example Usage:
	mediator = require 'window-event-mediator'
	mediator.on 'resize', myCallback
	mediator.off 'scroll', mycallback
###

# Deps
forEachRight = require 'lodash/forEachRight'
throttle = require 'lodash/throttle'
debounce = require 'lodash/debounce'
remove = require 'lodash/remove'
merge = require 'lodash/merge'

# Class definition
class WindowEventMediator

	# Stores a record on all event listener types, subscribed callbacks, and
	# Throttle/Debounce option keys
	handlers: {}

	# Default options
	defaults:
		throttle: 100
		debounce: 0
		dispatcher:
			scroll: window  # Included as an example of how this can be used
			default: window

	###
	Register an event handler with the mediator

	event - string - event name ('resize', 'scroll', etc) callback - function
	options
		throttle [100] - int - milliseconds to throttle
		debounce [100] - int - milliseconds to debounce
	###
	on: (event, callback, options) =>
		options = merge {}, @defaults, options
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
			options = merge {}, @defaults, options
			key = options.throttle+'-'+options.debounce
			if @handlers[event][key]?
				remove @handlers[event][key], (cbs) -> cbs.original == callback
				delete @handlers[event][key] if @handlers[event][key].length == 0
		else
			for key of @handlers[event]
				remove @handlers[event][key], (cbs) -> cbs.original == callback
				delete @handlers[event][key] if @handlers[event][key].length == 0

	###
	Create an event container for the window event type and
	add the actual listener to the window object

	event - string - event name ('resize', 'scroll', etc)
	###
	set: (event, callback, options) =>
		key = options.throttle + '-' + options.debounce

		# If the event type hasn't been added, create an object to store the
		# callbacks and a record of which throttle.debounce listeners have been
		# added
		@handlers[event] = {} if !@handlers[event]?

		# Determine which dispatcher to listen to
		dispatcher = options.dispatcher[event] ? options.dispatcher.default

		# Only add the window listener if it doesn't exist
		if !@handlers[event].hasOwnProperty(key)
			@handlers[event][key] = []
			dispatcher.addEventListener event, @fire

		# Save the callback references, including the original event for removing later
		@handlers[event][key].push
			modified: debounce(throttle(callback, options.throttle), options.debounce)
			original: callback

	###
	Fires all events for a given window event type, padding the native event
	object through to the mediated callback. It must be looped through backwards
	so that callbacks which are removed during the loop don't break the
	iteration.

	e - Event - native event object
	###
	fire: (e) =>
		forEachRight @handlers[e.type], (bag) ->
			forEachRight bag, (cbs) -> cbs.modified(e); return true

# This operates as a singleton
module.exports = new WindowEventMediator()

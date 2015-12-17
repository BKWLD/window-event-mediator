# Window Event Mediator
#### Mediator pattern for window event handling

* Example Usage:
```
mediator = require 'window-event-mediator'
mediator.add 'resize', myCallback, { throttle: 40 }
mediator.remove 'scroll', myOtherCallback
```

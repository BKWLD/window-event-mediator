# Window Event Mediator
#### Mediator pattern for window event handling

Example Usage:

```
mediator = require 'window-event-mediator'
mediator.on 'resize', myCallback, { throttle: 40 }
mediator.off 'scroll', myCallback
```

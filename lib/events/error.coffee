###

  The Norma error event is an event driven method for
  handling operational errors of systems that use
  and depend on the Norma build environment. The error
  event has three levels of level which are determined
  by the error object passed on the emittance.

###
Chalk = require "chalk"


module.exports = ->

  errorType = {}

  # This is the simplest message. It logs out message with any
  # extra information available.
  errorType.log = (msg) ->

    msg.level = "log"

    Norma.events.emit "message", msg


  # The warn level should try to let the developer know of the message
  # the norma-notify package is a great example of this event usage
  errorType.warn = (msg) ->

    Norma.events.emit "warn", msg

    errorType.log msg


  ###

    The crash level of error events ends the operation of Norma
    This is a last case result where the operation cannot procede
    correctly do to an error. These are rare.

  ###

  errorType.crash = (msg) ->

    Norma.events.emit "crash", msg

    msg.level = "log"
    Norma.events.emit "message", msg


    Norma.events.emit "stop"




  Norma.events.on "error", (error) ->

    # if error.domainThrown
    #   errorType.crash error

    if typeof error is "string"

      error =
        message: error
        level: "log"
        name: "Log"
        color: "red"

    if !error.color then error.color = "red"

    if error.level
      errorType[error.level] error

    else
      errorType.log error

###

  The Norma error event is an event driven method for
  handling operational errors of systems that use
  and depend on the Norma build environment. The error
  event has three levels of level which are determined
  by the error object passed on the emittance.

###

Chalk = require "chalk"
Log = require "./message"
Norma = require "./../norma"


error =

  # This is the simplest message. It logs out message with any
  # extra information available.
  log: (msg) ->

    msg.level = "log"
    Log msg


  # The warn level should try to let the developer know of the message
  # the norma-notify package is a great example of this event usage
  warn: (msg) =>

    Norma.emit "warn", msg
    msg.level = "log"

    Log msg


  ###

    The crash level of error events ends the operation of Norma
    This is a last case result where the operation cannot procede
    correctly do to an error. These are rare.

  ###

  crash: (msg) ->

    Norma.emit "crash", msg

    msg.level = "log"
    Log msg

    # Norma.stop()



module.exports = Error = (err) ->

  if !err
    return

  if typeof err is "string"

    err =
      message: err
      level: "log"
      name: "Log"
      color: "red"


  if !err.color then err.color = "red"

  if Norma.silent
    return

  if err.level
    error[err.level] err

  else
    error.log err

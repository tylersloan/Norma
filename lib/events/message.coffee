###

  The Norma message event is an event driven method for handling
  communication between Norma and the system or developer.
  Message events can be used to log information, notify the
  developer of something, or even communicate to a server
  or chat platform (hubot, HipChat).

###
Chalk = require "chalk"
Norma = require "./../norma"

message =

  # This is the simplest message. It logs out message with any
  # extra information available.
  log: (msg) ->

    message = [Chalk.grey(Norma._.prefix)]


    if Norma.prompt._.initialized and Norma.prompt.open
      Norma.prompt.pause()
      message = []

    # Build the error message by priority
    # if msg.name
    #   message.push Chalk.grey(Norma.prefix + msg.name + ": ")

    if msg.message
      if msg.color
        message.push Chalk[msg.color] msg.message
      else
        message.push Chalk.grey msg.message


    if msg.fileName
      message.push Chalk.green(msg.fileName)


    if msg.lineNumber
      if msg.fileName
        message.push ": #{msg.lineNumber} \n"
      else
        message.push "Line: #{msg.lineNumber} \n"


    if msg.stack
      message.push msg.stack


    console.log message.join ""

    if Norma.prompt._.initialized and !Norma.prompt.open

      Norma.prompt()




  # The notify level should try to let the developer know of the message
  # the norma-notify package is a great example of this event usage
  notify: (msg) ->

    Norma.emit "notify", msg

    messageType.log msg


  # The alert is the highest level of serverity of the message.
  # It should be used for external coummincation services to let
  # more than one person know what is happening.
  alert: (msg) ->

    Norma.emit "alert", msg

    messageType.notify msg




module.exports = Log = ->

  args = Array::.slice.call(arguments)

  for arg in args
    if typeof arg is "string"

      arg =
        message: arg
        level: "log"
        name: "Log"

    if Norma.silent and arg.type isnt "alert"
      return


    if arg.level
      message[arg.level] arg

    else
      message.log arg

  return

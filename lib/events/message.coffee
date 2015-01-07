###

  The Norma message event is an event driven method for handling
  communication between Norma and the system or developer.
  Message events can be used to log information, notify the
  developer of something, or even communicate to a server
  or chat platform (hubot, HipChat).

###
Chalk = require "chalk"


module.exports = ->

  messageType = {}

  # This is the simplest message. It logs out message with any
  # extra information available.
  messageType.log = (msg) ->

    message = [Chalk.grey(Norma.prefix)]

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


  messageType.debug = (msg) ->

    if Norma.debug
      msg.color = "red"
      messageType.log msg

  # The notify level should try to let the developer know of the message
  # the norma-notify package is a great example of this event usage
  messageType.notify = (msg) ->

    Norma.events.emit "notify", msg

    messageType.log msg


  # The alert is the highest level of serverity of the message.
  # It should be used for external coummincation services to let
  # more than one person know what is happening.
  messageType.alert = (msg) ->

    Norma.events.emit "alert", msg

    messageType.notify msg



  Norma.events.on "message", (message) ->


    if typeof message is "string"

      message =
        message: message
        level: "log"
        name: "Log"

    if Norma.silent and message.type isnt "alert"
      return


    if message.level
      messageType[message.level] message

    else
      messageType.log message

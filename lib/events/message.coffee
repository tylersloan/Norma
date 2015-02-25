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

    output = [Chalk.grey(Norma._.prefix)]


    if Norma.prompt._.initialized and Norma.prompt.open
      Norma.prompt.pause()
      output = []

    # Build the error output by priority
    # if msg.name
    #   output.push Chalk.grey(Norma.prefix + msg.name + ": ")

    if msg.message
      if msg.color
        output.push Chalk[msg.color] msg.message
      else
        output.push Chalk.grey msg.message


    if msg.fileName
      output.push Chalk.green(msg.fileName)


    if msg.lineNumber
      if msg.fileName
        output.push ": #{msg.lineNumber} \n"
      else
        output.push "Line: #{msg.lineNumber} \n"


    if msg.stack
      output.push msg.stack


    console.log output.join ""

    if Norma.prompt._.initialized and !Norma.prompt.open

      Norma.prompt()




  # The notify level should try to let the developer know of the message
  # the norma-notify package is a great example of this event usage
  notify: (msg) ->

    Norma.emit "notify", msg

    message.log msg


  # The alert is the highest level of serverity of the message.
  # It should be used for external coummincation services to let
  # more than one person know what is happening.
  alert: (msg) ->

    Norma.emit "alert", msg

    message.notify msg




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

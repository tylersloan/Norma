Path = require "path"
Fs = require "fs"
_ = require "underscore"
Q = require "kew"
Spawn = require("child_process").spawn

Norma = require "./../norma"


module.exports = (action, cwd, callback) ->

  if typeof cwd is "function"
    callback = cwd
    cwd = process.cwd()

  cwd or= process.cwd()


  if typeof action is "string"

    # split action into args
    actionArray = action.split " "


    ###

      Round one: check existing Norma packages

    ###
    if Norma.tasks[actionArray[0]]

      Norma.build([actionArray[0]], cwd)
        .then( (result) ->
          callback null, result
        )
        .fail( (error) ->
          callback error
        )

      return


    ###

      Round two: check to see if string is a path

    ####
    if Fs.existsSync Path.resolve(cwd, actionArray[0])
      action = "node"
      commands = [Path.resolve(cwd, actionArray[0])]

    else
      ###

        Round three: all else has failed so run the string as
        a shell command

      ###
      action = actionArray[0]
      # copy array for shifting
      commands = actionArray.slice()
      # remove first item
      commands.shift()


    # SHELL --------------------------------------------------

    ###

      For this shell we are inheriting output and input streams
      to the host stream instead of binding our own logging.
      Since this script could / should be used for testing
      frameworks, most frameworks have their own output methods
      and reporters, trying to map those to Norma seems like a
      waste of time.

    ###
    _action = Spawn(
      action
      commands
      {
        cwd: cwd
        stdio: [0, 1, 2]
      }
    )

    _action.on "close", (code, signal) ->

      if code is not 0
        callback signal
        return

      callback null, code

      return

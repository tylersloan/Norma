
Chalk = require "chalk"


module.exports = ->

  Norma.end = ->
    process.exit(0)

  Norma.stop  = ->
    Norma.emit "stop"

  Norma.events.on "stop", ->

    if Norma.verbose
      Norma.emit "message", Chalk.grey("exiting...")

    Norma.end()

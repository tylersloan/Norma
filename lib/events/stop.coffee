
Chalk = require "chalk"


module.exports = ->

  Norma.events.on "stop", ->
    setTimeout (->
      console.log "This will not run"
      return
    ), 10


  Norma.events.on "stop", ->

    if Norma.verbose
      Norma.emit "message", Chalk.grey("exiting...")

    Norma.end()


  Norma.end = ->
    process.exit(0)

  stop = ->
    Norma.emit "stop"
  Norma.stop = stop


Q = require "kew"


module.exports = (Norma) ->

  Norma.end = ->
    process.exit(0)


  Norma.stop  = ->

    promiseFunctions = new Array
    functions =  Norma.events.listeners "stop"

    obj = {}
    count = 1

    # Build dynamic list of defered functions
    for fn in functions
      count++
      obj[count] = Q.defer()

      fn obj[count].makeNodeResolver()
      promiseFunctions.push obj[count]

    # once all stop events are done exit
    Q.all(promiseFunctions)
      .then( ->
        if Norma.verbose
          Norma.emit "message", "exiting..."
        Norma.end()
      )

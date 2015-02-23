
Q = require "kew"


end = ->
  process.exit 0


close = ->

  promiseFunctions = new Array
  functions = Norma.listeners "stop"

  obj = {}
  count = 1

  # if !functions.length
  #   if Norma.verbose
  #     Norma.emit "message", "exiting..."
  #   end()

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
      end()
    )


module.exports = (Norma) ->
  
  return close

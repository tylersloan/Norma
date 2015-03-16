
Q = require "kew"

Norma = require "./../norma"


end = ->

  code = if Norma._.status then Norma._.status else 0

  if Norma._.bin

    process.exit code
  else
    return



module.exports = (stayAlive) ->

  if Norma.watchStarted
    Norma.watch.stop()

  promiseFunctions = new Array
  functions = Norma.listeners "close"

  obj = {}
  count = 1

  if !functions.length
    if Norma.verbose
      Norma.emit "message", "exiting..."

    if stayAlive
      return

    end()

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

      if stayAlive
        return

      end()
    )



Path = require "path"
Fs = require "fs"

Norma = require "./../norma"
main = Path.resolve __dirname, "../../", "bin/norma.js"


# restart = ->
#   process.exit 0


module.exports = restart = ->
  console.log "restarting"

  Norma.close(true)

  name = Norma.getSettings.get "user:name"

  if name then name = " " + name else name = ""

  Norma.log "I'm restarting#{name}..."

  Norma.ready(Norma.args, Norma._.cwd).then( ->

    Norma.run Norma.args, Norma._.cwd

    Norma.emit "restart"

  ).fail( (err) ->

    # Map captured errors back to domain
    Norma.domain._events.error err
  )

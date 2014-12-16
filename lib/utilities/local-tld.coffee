# An app’s API to ~/.local-tld.json
Fs = require "fs-extra"
Path = require "path"


readJSON = (filename, defaultValue) ->

  try
    return JSON.parse Fs.readFileSync(filename)
  catch e
    return defaultValue or {}

  return


writeJSON = (filename, value) ->

  Fs.writeFileSync filename + ".tmp", JSON.stringify(value)
  Fs.renameSync filename + ".tmp", filename

  return


module.exports.tld = Path.resolve process.env.HOME + "/.local-tld.json"
module.exports.basePort = 6000


# GET --------------------------------------------------------------------

getPort = (name) ->

  map = readJSON module.exports.tld

  maxPort = module.exports.basePort

  for port of map
    port = parseInt port, 10
    maxPort = port if port > maxPort

    mappedName = map[port].name

    if mappedName is name
      return port

  newPort = maxPort + 1
  map[newPort] =
    name: name

  writeJSON module.exports.tld, map

  newPort

module.exports.getPort = getPort


# SET --------------------------------------------------------------------

setAlias = (name, alias) ->

  map = readJSON module.exports.tld

  for port of map
    mappedName = map[port].name

    if mappedName is name

      if !map[port].aliases
        map[port].aliases = {}

      map[port].aliases[alias] = true

      writeJSON module.exports.tld, map

      return true
  false

module.exports.setAlias = setAlias


# ADD --------------------------------------------------------------------

addPort = (name, port) ->

  map = readJSON module.exports.tld

  entry = map[port]

  if entry and entry.name isnt name
    err = new Error("This port is already defined within ltld.")

    err.type = "warn"

    Norma.events.emit "error", err

  else if entry and entry.name is name
    return

  map[port] =
    name: name

  writeJSON module.exports.tld, map

module.exports.add = addPort


# REMOVE -----------------------------------------------------------------

removePort = (port) ->

  map = readJSON module.exports.tld

  if map[port]

    delete map[port]

    writeJSON module.exports.tld, map


module.exports.remove = removePort

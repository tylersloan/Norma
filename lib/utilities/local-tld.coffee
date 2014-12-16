# An app’s API to ~/.local-tld.json
fs = require("fs-extra")

module.exports.tld_file = process.env.HOME + "/.local-tld.json"
module.exports.base_port = 6000
module.exports.add = setPort = (name, port) ->
  map = read_json(module.exports.tld_file)
  entry = map[port]
  if entry and entry.name isnt name
    console.log entry
    console.log name
    throw new Error("This port is already defined within ltld.")
  else return  if entry and entry.name is name
  map[port] = name: name
  write_json module.exports.tld_file, map
  return

module.exports.remove = removePort = (name) ->
  map = read_json(module.exports.tld_file)
  port = module.exports.getPort(name)
  delete map[port]

  write_json module.exports.tld_file, map
  return

module.exports.getPort = getPort = (name) ->
  map = read_json(module.exports.tld_file)
  max_port = module.exports.base_port
  for port_m of map
    port_m = parseInt(port_m, 10)
    max_port = port_m  if port_m > max_port
    name_m = map[port_m].name
    return port_m  if name_m is name

  # if we got here, max_port is the highest registered port
  new_port = max_port + 1
  map[new_port] = name: name
  write_json module.exports.tld_file, map
  new_port

module.exports.setAlias = setAlias = (name, alias) ->
  map = read_json(module.exports.tld_file)
  for port_m of map
    name_m = map[port_m].name
    if name_m is name

      # found it
      map[port_m].aliases = {}  unless map[port_m].aliases
      map[port_m].aliases[alias] = true
      write_json module.exports.tld_file, map
      return true
  false

read_json = read_json = (filename, default_value) ->
  try
    return JSON.parse(fs.readFileSync(filename))
  catch e
    return default_value or {}
  return

write_json = write_json = (filename, value) ->
  fs.writeFileSync filename + ".tmp", JSON.stringify(value)
  fs.renameSync filename + ".tmp", filename
  return

###

  This file finds the norma.json for a project.
  It then parses it and returns the object as the result of the function

###

# Require packages
Fs = require "fs"
Path = require "path"
Chalk = require "chalk"
_ = require "underscore"
Lint = require "json-lint"

Norma = require "./../norma"

_process = (obj) ->

  # Iterate over arrays
  if Array.isArray(obj)
    return obj.map((val) ->
      _process val
    )

  # Iterate over object
  if typeof obj == 'object' and obj != null
    Object.keys(obj).forEach (key) ->
      obj[key] = _process(obj[key])
      return
    return obj

  # A string to test
  if typeof obj == 'string'
    # Not correct prefix?
    if obj.substr(0, 6) != 'EVAL:$'
      return obj
    # Get name and test existence
    name = obj.substr(6)
    # YIKES!
    name = eval(name)
    return name

  return obj


config = (cwd) ->

  if !cwd then cwd = process.cwd()

  # Find file based on cwd argument
  fileLoc = Path.join(cwd, "norma.json")

  # Create empty config object for empty returns
  _config = {}

  parse = (data) ->

    if data is `undefined`

      if !Norma.silent
        err =
          level: "crash"
          message: "norma.json is empty, have you initiated norma?"
          name: "Missing File"

        Norma.emit "error", err

      return false

    # Try parsing the config data as JSON
    try
      _config = JSON.parse(data)
      _process _config

    catch err

      lint = Lint data
      if lint.error
        err.message = "#{lint.error} This error was
          found on line #{lint.line} at character #{lint.character}"

      err.level = "crash"
      Norma.emit "error", err


      return false

  ###

    Try and read file
    This is done syncronously in order to return read data correctly

  ###

  if Fs.existsSync fileLoc
    try
      file = Fs.readFileSync fileLoc, encoding: "utf8"
    catch err
      err.level = "crash"


      Norma.emit "error", err
      return false

  else return false


  return parse(file)





save = (obj, cwd) ->


  if !cwd then cwd = process.cwd()

  if !_.isObject obj
    Norma.emit "error", "Cannot save norma.json without and object passed to save"
    return false

  # Save config
  try
    Fs.writeFileSync(
      Path.join(cwd, "norma.json")
      JSON.stringify(obj, null, 2)
    )
  catch err

    Norma.emit "error", "Cannot save norma.json"
    return false


  return true


# Return the config object
module.exports = config
module.exports.save = save

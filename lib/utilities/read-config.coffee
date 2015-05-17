###

  This file finds the norma file for a project.
  It then parses it and returns the object as the result of the function

###

# Require packages
Fs = require "fs"
Path = require "path"
Chalk = require "chalk"
_ = require "underscore"
Lint = require "json-lint"
CSON = require "cson"

Norma = require "./../norma"

_process = (obj) ->

  # Iterate over arrays
  if Array.isArray(obj)
    return obj.map((val) ->
      _process val
    )

  # Iterate over object
  if typeof obj is "object" and obj isnt null
    Object.keys(obj).forEach (key) ->
      obj[key] = _process(obj[key])
      return
    return obj

  # A string to test
  if typeof obj is "string"
    # Not correct prefix?
    if obj.substr(0, 6) isnt "EVAL:$"
      return obj
    # Get name and test existence
    name = obj.substr(6)
    # YIKES!
    name = eval(name)
    return name

  return obj


getExt = (cwd) ->

  ext = "json"

  cson = Path.join(cwd, "norma.cson")
  if Fs.existsSync cson
    ext = "cson"

  return ext


config = (cwd) ->


  if !cwd then cwd = process.cwd()

  # Find file based on cwd argument
  ext = getExt(cwd)


  fileLoc = Path.join(cwd, "norma.#{ext}")


  parse = (data) ->

    if data is `undefined`

      if !Norma.silent
        err =
          level: "crash"
          message: "norma.json is empty, have you initiated norma?"
          name: "Missing File"

        Norma.emit "error", err

      return false

    # Create empty config object for empty returns
    data or= {}

    data = _process(data)

    return data




  ###

    Try and read file
    This is done syncronously in order to return read data correctly

  ###

  if Fs.existsSync fileLoc
    try
      file = CSON.parseFile fileLoc
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


  process = (obj) ->
    ext = getExt()

    if ext is "cson"
      obj = CSON.stringify(obj)
    else
      obj = JSON.stringify(obj)

    return obj


  # Save config
  try
    Fs.writeFileSync(
      Path.join(cwd, "norma.json")
      JSON.stringify(process(obj), null, 2)
    )
  catch err

    Norma.emit "error", "Cannot save norma.json"
    return false


  return true


# Return the config object
module.exports = config
module.exports.save = save

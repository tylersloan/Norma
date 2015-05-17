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



getFile = (cwd) ->

  cson = Path.join(cwd, "norma.cson")
  if Fs.existsSync cson
    return cson

  file =  Path.join(cwd, "norma.json")
  if Fs.existsSync file
    return file

  _norma = Path.join(cwd, "Norma")
  return _norma


config = (cwd) ->

  cwd or= process.cwd()

  # Find file based on cwd argument
  fileLoc = getFile cwd


  parse = (data) ->

    if data is `undefined`

      if !Norma.silent
        err =
          level: "crash"
          message: "norma file is empty, have you initiated norma?"
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



exists = (cwd) ->

  cwd or= process.cwd()

  return Fs.existsSync(getFile(cwd))


save = (obj, cwd) ->


  if !_.isObject obj
    Norma.emit "error", "Cannot save norma file without and object passed to save"
    return false

  cwd or= process.cwd()

  process = (obj) ->

    ext = Path.extname(getFile(cwd))

    if ext is ".json"
      obj = JSON.stringify(obj, null, 2)
    else
      obj = CSON.stringify(obj)

    return obj


  # Save config
  try
    Fs.writeFileSync(
      getFile(cwd)
      process(obj)
    )
  catch err

    Norma.emit "error", "Cannot save #{getFile(cwd)}"
    return false


  return true


# Return the config object
module.exports = config
module.exports.save = save
module.exports.exists = exists

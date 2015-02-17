###

  This file finds the norma.json for a project.
  It then parses it and returns the object as the result of the function

###

# Require packages
Fs = require "fs"
Path = require "path"
Chalk = require "chalk"
_ = require "underscore"


config = (cwd) ->


  if !cwd then cwd = process.cwd()

  # Find file based on cwd argument
  fileLoc = Path.join(cwd, "norma.json")

  # Create empty config object for empty returns
  _config = {}

  parse = (data) ->

    if data is `undefined`

      err =
        level: "crash"
        message: "norma.json is empty, have you initiated norma?"
        name: "Missing File"

      Norma.emit "error", err

    # Try parsing the config data as JSON
    try
      _config = JSON.parse(data)
    catch err

      err.level = "crash"
      err.message = "norma.json is not a valid JSON"

      Norma.emit "error", err

  ###

    Try and read file
    This is done syncronously in order to return read data correctly

  ###
  try
    file = Fs.readFileSync fileLoc, encoding: "utf8"
  catch err
    err.level = "crash"
    err.message= "Cannot find norma.json. Have you initiated norma?"

    Norma.emit "error", err


  parse file




save = (obj, cwd) ->

  if !cwd then cwd = process.cwd()

  if !_.isObject obj
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

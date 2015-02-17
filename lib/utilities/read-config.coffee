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


config = (cwd) ->

  if !cwd then cwd = process.cwd()

  # Find file based on cwd argument
  fileLoc = Path.join(cwd, "#{Tool}.json")

  # Create empty config object for empty returns
  _config = {}

  parse = (data) ->

    if data is `undefined`

      err =
        level: "crash"
        message: "#{Tool}.json is empty, have you initiated #{Tool}?"
        name: "Missing File"

      Norma.events.emit "error", err

    # Try parsing the config data as JSON
    try
      _config = JSON.parse(data)
    catch err

      lint = Lint data
      if lint.error
        err.message = "#{lint.error} This error was
          found on line #{lint.line} at character #{lint.character}"

      err.level = "crash"
      # err.message = "#{Tool}.json is not a valid JSON"

      Norma.events.emit "error", err

  ###

    Try and read file
    This is done syncronously in order to return read data correctly

  ###
  try
    file = Fs.readFileSync fileLoc, encoding: "utf8"
  catch err
    err.level = "crash"
    err.message= "Cannot find #{Tool}.json. Have you initiated #{Tool}?"

    Norma.events.emit "error", err


  parse file




save = (obj, cwd) ->

  if !cwd then cwd = process.cwd()

  if !_.isObject obj
    return false

  # Save config
  try
    Fs.writeFileSync(
      Path.join(cwd, "#{Tool}.json")
      JSON.stringify(obj, null, 2)
    )
  catch err

    Norma.events.emit "error", "Cannot save #{Tool}.json"
    return false


  return true


# Return the config object
module.exports = config
module.exports.save = save

###

  This file finds the norma.json for a project.
  It then parses it and returns the object as the result of the function

###

# Require packages
Fs = require "fs"
Path = require "path"
Chalk = require "chalk"

module.exports = (cwd) ->

  # Find file based on cwd argument
  fileLoc = Path.join(cwd, "#{Tool}.json")

  # Create empty config object for empty returns
  config = {}

  parse = (data) ->

    if data is `undefined`

      err =
        level: "crash"
        message: "Cannot find #{Tool}.json. Have you initiated norma?"
        name: "Missing File"

      Norma.events.emit "error", err

    # Try parsing the config data as JSON
    try
      config = JSON.parse(data)
    catch err

      err.level = "crash"

      Norma.events.emit "error", err



  ###

    Try and read file
    This is done syncronously in order to return read data correctly

  ###
  try
    file = Fs.readFileSync fileLoc, encoding: "utf8"
  catch err
    err.level = "crash"

    Norma.events.emit "error", err


  parse file

  # Return the config object
  return config

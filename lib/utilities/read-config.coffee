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
      console.log err
      err.level = "crash"


      Norma.emit "error", err
      return false

  else return false


  return parse(file)





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

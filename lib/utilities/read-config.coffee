###

  This file finds the norma.json for a project.
  It then parses it and returns the object as the result of the function

###

# Require packages
Fs = require "fs-extra"
Path = require "path"
Chalk = require "chalk"

module.exports = (cwd) ->

  # Find file based on cwd argument
  fileLoc = Path.join(cwd, "#{Tool}.json")

  # Create empty config object for empty returns
  config = {}

  parse = (data) ->

    if data is `undefined`
      console.log(
        Chalk.red "Cannot find #{Tool}.json. Have you initiated norma?"
      )
      process.exit 0

    # Try parsing the config data as JSON
    try
      config = JSON.parse(data)
    catch err
      console.log(
        Chalk.red "The #{Tool}.json file is not valid json. Aborting."
        , err
      )
      process.exit 0


  ###

    Try and read file
    This is done syncronously in order to return read data correctly

  ###
  try
    file = Fs.readFileSync fileLoc, encoding: "utf8"
  catch err
    console.log(
      Chalk.red "Cannot find #{Tool}.json. Have you initiated norma?"
    )
    process.exit 0

  parse file

  # Return the config object
  return config

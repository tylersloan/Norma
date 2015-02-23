###

  In order to have a great build tool, I think each developer needs
  the ability to add their own preferences of how things are run.
  This file uses the awesome `nconf` package to store global and local
  config data. This allows devs to choose custom info system wise and
  project wise
  ~ @jbaxleyii

###

Fs    = require "fs"
Flags = require("minimist")(process.argv.slice(2))
Chalk = require "chalk"
Path = require "path"

Norma = require "./../norma"


module.exports = (tasks, cwd) ->

  # remove memory settings to use just files for CLI usage
  Norma.getSettings._.remove('memory')


  # CONFIG-TYPE -----------------------------------------------------------

  ###

    If command has been run with --global or --g then
    swich to the global config, otherwise use current
    directory level to create and use config (local)

  ###
  if Norma.global
    Norma.getSettings._.remove "local"
  else
    Norma.getSettings._.remove "global"



  # READ ------------------------------------------------------------------

  # Empty config command returns print out of config
  if !tasks.length

    configData = Norma.getSettings()

    # Print out cofing data for easy lookup
    console.log configData


  # KEY-TASKS ------------------------------------------------------------

  # Read config of a value
  if tasks[0] and tasks[1] is `undefined`


    # Gives users the options to remove config items
    if !Flags.remove
      msg = Chalk.cyan( tasks[0] + ": ") +
        Norma.getSettings.get(tasks[0])

      Norma.emit "message", msg
    else
      Norma.getSettings._.clear tasks[0]



  # SAVE ------------------------------------------------------------------

  # Save config with value
  if tasks[1]
    Norma.getSettings._.set tasks[0], tasks[1]



  # RESET -----------------------------------------------------------------

  # Reset clears entire Nconf file
  if Flags.reset
    Norma.getSettings._.reset()


  # CONFIG-SAVE -----------------------------------------------------------


  # Save the configuration object to file
  Norma.getSettings._.save (err, data) ->
    throw err if err




# API ----------------------------------------------------------------------

module.exports.api = [
  {
    command: ""
    description: "print out current project config"
  }
  {
    command: "<key>"
    description: "print out value of local config key"
  }
  {
    command: "<key> --reset"
    description: "clear out value of local config key"
  }
  {
    command: "<key> value"
    description: "save value of local config key"
  }
  {
    command: "--reset"
    description: "clear out all local config items"
  }
  {
    command: "--global"
    description: "print out global config"
  }
  {
    command: "<key> --global"
    description: "print out value of global config key"
  }
  {
    command: "<key> --global --reset"
    description: "clear out value of global config key"
  }
  {
    command: "<key> value --global"
    description: "save value of global config key"
  }
  {
    command: "--reset --global"
    description: "clear out all global config items"
  }
]

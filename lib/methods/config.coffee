###

  In order to have a great build tool, I think each developer needs
  the ability to add their own preferences of how things are run.
  This file uses the awesome `nconf` package to store global and local
  config data. This allows devs to choose custom info system wise and
  project wise
  ~ @jbaxleyii

###

Fs    = require "fs-extra"
Nconf = require "nconf"
Flags = require("minimist")(process.argv.slice(2))
Chalk = require "chalk"
Path = require "path"


module.exports = (tasks, cwd) ->

  # CONFIG-TYPE -----------------------------------------------------------

  ###

    If command has been run with --global or --g then
    swich to the global config, otherwise use current
    directory level to create and use config (local)

  ###
  if Flags.global or Flags.g
    useDir = Path.resolve __dirname, "../../"
  else
    useDir = process.cwd()

  # See if a config file already exists (for local files)
  configExists = Fs.existsSync Path.join(useDir, ".#{Tool}")


  # CONFIG-CREATE ---------------------------------------------------------

  # If no file, then we create a new one with some preset items
  if !configExists
    config =
      Path: process.cwd()
      message : "Write custom config items in this file"

    # Save config
    Fs.writeFileSync(
      Path.join(useDir, ".#{Tool}")
      JSON.stringify(config, null, 2)
    )



  # CONFIG-READ -----------------------------------------------------------

  ###

    Setup Nconf to use (in-order):
      1. Command-line arguments
      2. Environment variables
      3. A file located at "Path/to/config.json"

  ###
  Nconf
    .env()
    .argv()
    .file("project", {
      file: ".#{Tool}",
      dir: useDir,
      search: true
    })



  # READ ------------------------------------------------------------------

  # Empty config command returns print out of config
  if !tasks.length

    # Set directory
    dir = Path.join useDir, ".#{Tool}"

    try
      file = Fs.readFileSync dir, encoding: "utf8"

      configData = JSON.parse file

    catch err

      err.level = "crash"

      err.message "The .#{Tool} file is not valid json. Aborting."


    # Print out cofing data for easy lookup
    console.log configData


  # KEY-TASKS ------------------------------------------------------------

  # Read config of a value
  if tasks[0] and tasks[1] is `undefined`


    # Gives users the options to remove config items
    if !Flags.remove
      console.log(
        Chalk.cyan( tasks[0] + ": ")
        Chalk.magenta( Nconf.get(tasks[0]))
      )
    else
      Nconf.clear tasks[0]



  # SAVE ------------------------------------------------------------------

  # Save config with value
  if tasks[1]
    Nconf.set tasks[0], tasks[1]



  # RESET -----------------------------------------------------------------

  # Reset clears entire Nconf file
  if Flags.reset
    Nconf.reset()


  # CONFIG-SAVE -----------------------------------------------------------

  # Save the configuration object to file
  Nconf.save (err) ->
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

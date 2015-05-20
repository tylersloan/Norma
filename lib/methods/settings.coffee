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
CSON = require "cson"
PrettyPrint = require "prettyjson"

Norma = require "./../norma"


module.exports = (tasks, cwd, global) ->


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

    if Object.keys(configData).length
      # Print out cofing data for easy lookup
      Norma.log(PrettyPrint.render(configData))



  prepareFile = (loc) ->

    dir = Path.resolve(loc, "../")
    packageJson = Path.resolve(dir, "../", "package.json")
    newPackage = Path.resolve(dir, "package.json")

    if Fs.existsSync(loc) and Fs.existsSync(newPackage)
      return

    dir = Path.resolve(loc, "../")

    if not Fs.existsSync dir
      Fs.mkdirSync dir

    Fs.writeFileSync loc

    if Fs.existsSync packageJson

      # read file
      # Using the require method keeps the same in memory, instead we use
      # a synchronous fileread of the JSON.
      config = Fs.readFileSync packageJson, encoding: "utf8"

      try
        config = JSON.parse(config)
      catch err
        err.level = "crash"

        Norma.emit "error", err

      # remove dependenices
      delete config["dependencies"]
      delete config["devDependencies"]
      delete config["peerDependencies"]

      # save
      try
        Fs.writeFileSync(
          newPackage
          JSON.stringify(config, null, 2)
        )
      catch err
        Norma.emit "error", "Cannot save #{getFile(cwd)}"

      return




  # SAVE ------------------------------------------------------------------

  # Save config with value
  if tasks[1]

    for store, obj of Norma.getSettings._.stores
      prepareFile obj.file

    Norma.getSettings.set tasks[0], tasks[1]
    msg = Chalk.cyan( tasks[0] + ": ") + tasks[1]
    Norma.log msg



  # KEY-TASKS ------------------------------------------------------------

  # Read config of a value
  if tasks[0] and not tasks[1]


    # Gives users the options to remove config items
    if !Flags.remove
      value = Norma.getSettings.get(tasks[0])
      msg = Chalk.cyan( tasks[0] + ": ") + value

      if value
        Norma.log msg
      else
        Norma.log "No value found for #{tasks[0]}"
    else
      if not Norma.global
        createLocal()
      Norma.getSettings._.clear tasks[0]




  # RESET -----------------------------------------------------------------

  # Reset clears entire Nconf file
  if Flags.reset
    if not Norma.global
      createLocal()
    Norma.getSettings._.reset()


  # CONFIG-SAVE -----------------------------------------------------------

  if Object.keys(Norma.getSettings()).length

    # Save the configuration object to file
    Norma.getSettings._.save (err, data) ->
      throw err if err
  else
    Norma.log "No settings found"



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

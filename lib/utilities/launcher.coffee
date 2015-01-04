###

  This is the main routing file for commands

###

Flags = require("minimist")( process.argv.slice(2) )
Chalk = require "chalk"
Path = require "path"
Home = require "user-home"
Fs = require "fs"

ReadConfig = require "./read-config"
RegisterPackages = require "./register-packages"
Logger = require "./../logging/logger"
ManageDependencies = require "./manage-dependencies"
ReadSettings = require "./read-settings"
BindModes = require "./bind-modes"
AutoUpdate = require "./auto-update"
Prompt = require "./prompt"
MkDir = require("./directory-tools").mkdir



module.exports = (env) ->

  Norma.root = Path.resolve __dirname, "../../"

  if Home

    MkDir Path.resolve Home, "#{Tool}"
    Norma.userHome = Path.resolve Home, "#{Tool}"

  else

    MkDir Path.resolve __dirname, "../../../${Tool}"
    Norma.userHome = Path.resolve __dirname, "../../../${Tool}"


  ###

    Change directory to where norma was called from.
    This allows the tool to work is way up the tree to find an norma.json.

  ###
  if process.cwd() isnt env.cwd
    process.chdir env.cwd


  # CONFIG -----------------------------------------------------------------

  # norma.json for local project
  Norma.config = (cwd) ->

    config = {}

    if !cwd
      config = ReadConfig process.cwd()

    else
      config = ReadConfig cwd

    return config



  # SETTINGS ---------------------------------------------------------------

  Norma.settings = ReadSettings



  # PROMPT -----------------------------------------------------------------

  Norma.prompt = Prompt



  # VARIABLES --------------------------------------------------------------

  # Get the package.json for norma info
  cliPackage = require Path.join __dirname, "../../package.json"

  # Bind tasks to variable for easy passing
  tasks = Flags._

  BindModes()



  # AUTOUPDATE --------------------------------------------------------------

  # This should only run locally
  if !Norma.production

    AutoUpdate tasks



  # UTILITY -----------------------------------------------------------------

  # Check for version flag and report version
  if Norma.version
    versionString = "#{Tool} CLI version: #{Chalk.cyan(cliPackage.version)}"
    Norma.emit "message", versionString

    # exit
    process.exit 0


  # See if help or h task is trying to be run
  if Norma.help

    Logger.logInfo(cliPackage)

    process.exit 0



  # REGISTER ---------------------------------------------------------------

  runTasks = (_tasks, cwd) ->

    # set default task to watch if running bare
    if _tasks.length is 0
      _tasks = ["watch"]

    ###

      This is where we need to register all packages prior
      to running any tasks

    ###
    noPackageTasks = [
      "add"
      "config"
      "create"
      "help"
      "init"
      "open"
      "remove"
      "search"
      "update"
    ]


    if noPackageTasks.indexOf(_tasks[0]) is -1

      pkges = RegisterPackages _tasks, cwd

    else
      pkges = {}

    # TASKS -----------------------------------------------------------------

    # Fire the start event
    Norma.events.emit "start"

    if pkges

      try
        task = require "./../methods/#{_tasks[0]}"
        action = _tasks.slice()
        action.shift()

        task action, cwd

      catch e
        pkge = _tasks.slice()

        method = pkge[0]
        pkge.shift()

        if pkge.length
          method += "-#{pkge[0]}"

        if pkges[method]
          pkges[method].fn ->
            return
        else
          e.level = "crash"
          Norma.events.emit "error", e

    # Fire the stop event
    # Norma.events.emit "stop"



  # DEPENDENCIES ------------------------------------------------------------

  name = Norma.settings.get "user:name"

  if name then name = " " + name else name = ""

  Norma.events.emit "message", "I'm getting everything ready#{name}..."

  ready = ManageDependencies(tasks, env.cwd)

  ready.then( ->

    runTasks tasks, env.cwd

  ).fail( (err) ->

    # Map captured errors back to domain
    Norma.domain._events.error err
  )

  module.exports.run = runTasks

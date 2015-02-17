###

  This is the main routing file for commands

###

Flags = require("minimist")( process.argv.slice(2) )
Chalk = require "chalk"
Path = require "path"
Home = require "user-home"
Fs = require "fs"

Norma = require "./../norma"


RegisterPackages = require "./register-packages"
Logger = require "./../logging/logger"
ManageDependencies = require "./manage-dependencies"
AutoUpdate = require "./auto-update"
MkDir = require("./directory-tools").mkdir
Ask = require ("./ask")



module.exports = (env, Norma) ->


  ###

    Change directory to where norma was called from.
    This allows the tool to work is way up the tree to find an norma.json.

  ###
  if process.cwd() isnt env.cwd
    process.chdir env.cwd



  # QUESTIONS --------------------------------------------------------------

  # Inquirer.prompt = Ask



  # VARIABLES --------------------------------------------------------------

  # Get the package.json for norma info
  cliPackage = require Path.join __dirname, "../../package.json"

  # Bind tasks to variable for easy passing
  tasks = Flags._



  # AUTOUPDATE --------------------------------------------------------------

  update = Norma.settings.get "autoupdate"

  # This should only run locally
  if !Norma.production or update is "false"

    AutoUpdate tasks, update



  # UTILITY -----------------------------------------------------------------

  # Check for version flag and report version
  if Norma.version

    versionString = "norma CLI version: #{Chalk.cyan(cliPackage.version)}"

    Norma.log versionString

    # exit
    Norma.stop()



  # See if help or h task is trying to be run
  if Norma.help
    tasks = ["help"]


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
        # task = require "./../methods/#{_tasks[0]}"
        task = Norma.method[_tasks[0]]
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

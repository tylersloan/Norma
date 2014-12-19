###

  This is the main routing file for commands

###

Flags = require("minimist")( process.argv.slice(2) )
Chalk = require "chalk"
Path = require "path"

ReadConfig = require "./read-config"
RegisterPackages = require "./register-packages"
Logger = require "./../logging/logger"
ManageDependencies = require "./manage-dependencies"


module.exports = (env) ->

  Norma.cwd = Path.resolve __dirname, "../../"

  # VARIABLES ----------------------------------------------------------------

  # Get the package.json for norma info
  cliPackage = require Path.join __dirname, "../../package.json"

  # Bind tasks to variable for easy passing
  tasks = Flags._



  # UTILITY ------------------------------------------------------------------

  # Check for version flag and report version
  if Flags.v or Flags.version

    console.log "#{Tool} CLI version", Chalk.cyan(cliPackage.version)

    # exit
    process.exit 0

  # set default task to watch if running bare
  if tasks.length is 0
    tasks = ["watch"]


  # See if help or h task is trying to be run
  if Flags.help or Flags.h

    Logger.logInfo(cliPackage)

    process.exit 0


  if Flags.verbose
    Norma.verbose = true


  if Flags.debug
    Norma.debug = true


  ###

    Change directory to where norma was called from.
    This allows the tool to work is way up the tree to find an norma.json.

  ###
  if process.cwd() isnt env.cwd
    process.chdir env.cwd
    console.log(
      Chalk.cyan("Working directory changed to", Chalk.magenta(env.cwd))
    )




  # REGISTER ---------------------------------------------------------------

  runTasks = (tasks, cwd) ->

    ###

      This is where we need to register all packages prior
      to running any tasks

    ###

    if tasks[0] is "build" or tasks[0] is "test" or tasks[0] is "watch"

      packagesReady = RegisterPackages tasks, cwd
    else
      packagesReady = true


    # TASKS -------------------------------------------------------------------


    if packagesReady

      # Fire the start event
      Norma.events.emit "start"


      try
        task = require "./../methods/#{tasks[0]}"

        tasks.shift()

        task tasks, cwd
      catch e
        e.level = "crash"
        Norma.events.emit "error", e

      # Fire the stop event
      # Norma.events.emit "stop"



  # DEPENDENCIES ------------------------------------------------------------

  Norma.events.emit "message", "Making sure everything is in place..."

  ready = ManageDependencies(tasks, env.cwd)

  ready.then( ->

    runTasks tasks, env.cwd

  ).fail( (err) ->

    # Map captured errors back to domain
    Norma.domain._events.error err
  )

  module.exports.run = runTasks

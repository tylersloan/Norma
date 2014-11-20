###

  This is the main routing file for commands

###

# Require the needed packages
Flags = require("minimist")( process.argv.slice(2) )
Chalk = require "chalk"
ReadConfig = require "./read-config"
PkgeLookup = require "./../utilities/package-lookup"
Path = require 'path'


# Logger is where console output info for the CLI is stored
Logger = require "./../logging/logger"


module.exports = (env) ->


  # VARIABLES ----------------------------------------------------------------

  # Get the package.json for norma info
  cliPackage = require "../../package"

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

    Change directory to where nsp was called from.
    This allows the tool to work is way up the tree to find an nspfile.

  ###
  if process.cwd() isnt env.cwd
    process.chdir env.cwd
    console.log(
      Chalk.cyan("Working directory changed to", Chalk.magenta(env.cwd))
    )


  # REGISTER ---------------------------------------------------------------

  ###

    This is where we need to register all processes prior
    to running any tasks

  ###

  if tasks[0] is 'do' or tasks[0] is 'test'

    config = ReadConfig process.cwd()

    ###

      Also the package lookup method should be able to handle this portion as well
      although it might need to be modified slightly

      ~ @jbaxleyiii

    ###

    if tasks[0] is 'test'
      main = config.main or "package.coffee"
      testPackage = require "#{process.cwd()}/#{main}"
      testPackage config, tasks

    else if config.processes

      for key, val of config.processes

        rootOfProcess = Path.join process.cwd(), "node_modules", "#{Tool}-#{key}"
        processPackage = require Path.join rootOfProcess, "package.coffee"
        processPackage config, tasks


  # TASKS -------------------------------------------------------------------


  ###

    Should we remove the first argument since that is the file name?
    Also this should be wrapped in a try method and log errors

    @rich

  ###
  task = require "./../methods/#{tasks[0]}"
  task tasks, env.cwd

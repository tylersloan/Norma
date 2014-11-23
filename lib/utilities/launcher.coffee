###

  This is the main routing file for commands

###

# Require the needed packages
Flags = require("minimist")( process.argv.slice(2) )
Chalk = require "chalk"


ReadConfig = require "./read-config"
RegisterPackages = require "./register-packages"


Path = require 'path'


# Logger is where console output info for the CLI is stored
Logger = require "./../logging/logger"


module.exports = (env) ->

  Norma.cwd = Path.resolve __dirname, "../../"
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

    This is where we need to register all packages prior
    to running any tasks

  ###

  if tasks[0] is "build" or tasks[0] is "test" or tasks[0] is "watch"
    packagesReady = RegisterPackages tasks, env.cwd
  else
    packagesReady = true


  # TASKS -------------------------------------------------------------------


  ###

    Should we remove the first argument since that is the file name?
    Also this should be wrapped in a try method and log errors

    @rich

  ###
  if packagesReady

    try
      task = require "./../methods/#{tasks[0]}"
      task tasks, env.cwd
    catch e
      error = new Norma.error "require fail", e

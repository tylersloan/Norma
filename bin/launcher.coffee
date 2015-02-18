###

  This is the main routing file for the CLI

###

Flags = require("minimist")( process.argv.slice(2) )
Chalk = require "chalk"
Path = require "path"
Fs = require "fs"

Norma = require "../lib/norma"
AutoUpdate = require "./auto-update"


module.exports = (env) ->

  # AUTOUPDATE --------------------------------------------------------------

  update = Norma.getSettings.get "autoupdate"

  # This should only run locally
  if !Norma.production or update is "false"
    AutoUpdate update

  # UTILITY -----------------------------------------------------------------

  # Check for version flag and report version
  if Flags.version

    versionString = "norma CLI version: #{Chalk.cyan(Norma.version)}"

    Norma.log versionString

    # exit
    Norma.close()



  # # See if help or h task is trying to be run
  if Flags.help
    Norma._ = ["help"]


  # DEPENDENCIES ------------------------------------------------------------

  name = Norma.getSettings.get "user:name"

  if name then name = " " + name else name = ""

  Norma.log "I'm getting everything ready#{name}..."

  Norma.ready(Norma._, env.cwd).then( ->

    Norma.run Norma._, env.cwd


  ).fail( (err) ->

    # Map captured errors back to domain
    Norma.domain._events.error err
  )

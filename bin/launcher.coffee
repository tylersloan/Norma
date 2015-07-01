###

  This is the main routing file for the CLI

###

Flags = require("minimist")( process.argv.slice(2) )
Chalk = require "chalk"
Path = require "path"
Fs = require "fs"
Q = require "kew"
Flags = require("minimist")( process.argv.slice(2) )


Norma = require "../lib/norma"
AutoUpdate = require "./auto-update"


module.exports = (env) ->
  Norma.args = Flags._


  # we only notify for updates if we are in a long running process (watch)
  Norma.on("watch-start", ->

    # AUTOUPDATE --------------------------------------------------------------

    update = Norma.getSettings.get "autoupdate"

    # # This should only run locally
    if !Norma.production or !process.env.CI or update is "false"
      AutoUpdate update

  )


  # UTILITY -----------------------------------------------------------------

  # Check for version flag and report version
  if Flags.version or Flags.v

    versionString = "norma CLI version: #{Chalk.cyan(Norma._.version)}"

    Norma.log versionString

    # exit
    Norma.close()



  # # See if help or h task is trying to be run
  if Flags.help and not Norma.args.length
    Norma.args = ["help"]

  if Flags.test and not Norma.args.length
    Norma.args = ["test"]

  # DEPENDENCIES ------------------------------------------------------------

  name = Norma.getSettings.get "user:name"

  if name then name = " " + name else name = ""

  Norma.log "I'm getting everything ready#{name}..."

  promises = [
    Norma.ready(Norma.args, env.cwd)
    Norma.ready(Norma.args, Path.join(env.cwd, ".norma") )
  ]

  Q.all(promises)
    .then( ->

      Norma.run Norma.args, env.cwd


    ).fail( (err) ->

      # Map captured errors back to domain
      Norma.domain._events.error err
    )

Path          = require "path"
Util          = require "util"
_             = require "underscore"
Fs            = require "fs"

MapTree = require("./utilities/directory-tools").mapTree

module.exports = (Norma) ->


  ###

    Prompt

    Version of readline interface for prompt during watch

    @method prompt
    @api public

  ###
  Norma.prompt = require "./utilities/prompt"


  ###

    Log

    Console logging binding for norma messaging system

    @method log
    @event "message", "log"
    @api public

  ###
  Norma.log = require "./events/message"
  Norma.on "message", Norma.log
  Norma.on "log", Norma.log



  ###

    Error

    Error binding for norma messaging system

    @method error
    @event "error"
    @api public

  ###
  Norma.error = require "./events/error"
  Norma.on "error", Norma.error


  ###

    Stop

    Promise based process ending

    @method close
    @api public

  ###
  Norma.close = require "./events/close"



  ###

    Restart

    Graceful restarts

    @method close
    @api public

  ###
  Norma.restart = require "./events/restart"



  ###

    getSettings

    Return in-memory storage of global + local .norma files

    @method getSettings
    @api public

  ###
  Norma.getSettings = require "./utilities/read-settings"


  ###

    config

    Return object of norma.json file

    @method getSettings
    @api public

  ###
  Norma.config = require "./utilities/read-config"



  ###

    execute

    A mapping of run-sequence to orchestrator for complex builds

    @method execute
    @api public

  ###
  Norma.execute = require "./utilities/orchestration"


  ###

    ready

    Ensures all dependencies for running are ready

    @method ready
    @api public

  ###
  Norma.ready = require "./utilities/manage-dependencies"



  ###

    ready

    Ensures all dependencies for running are ready

    @method getPackages
    @api public

  ###
  Norma.getPackages = require "./utilities/register-packages"



  ###

    bind-modes

    A mapping of arguments (--flags), env properties (dev vs production)
    and settings from the user

  ###
  require("./utilities/bind-modes")(Norma)


  ###

    method binding for all options in /methods

  ###
  do ->
    methodDir = Path.resolve __dirname, "./methods/"
    methods = MapTree methodDir

    for method in methods.children
      name = Path.basename(method.name, Path.extname(method.name))

      Norma[name] = require(method.path) if method.path

  Norma.i = Norma.install



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

    .05 s added to load

  ###
  Norma.prompt = require "./utilities/prompt"


  ###

    Log

    Console logging binding for norma messaging system

    @method log
    @event "message", "log"
    @api public

    .019 s added to load

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

    .013 s added to load

  ###
  Norma.error = require "./events/error"
  Norma.on "error", Norma.error

  ###

    Stop

    Promise based process ending

    @method close
    @api public

    .014 s added to load

  ###
  Norma.close = require "./events/close"


  ###

    Restart

    Graceful restarts

    @method close
    @api public

    .006 s added to load

  ###
  Norma.restart = require "./events/restart"


  ###

    getSettings

    Return in-memory storage of global + local .norma files

    @method getSettings
    @api public

    .083 s added to load

  ###
  Norma.getSettings = require "./utilities/read-settings"


  ###

    config

    Return object of norma file

    @method getSettings
    @api public

    .023 s added to load

  ###
  Norma.config = require "./utilities/read-config"



  ###

    execute

    A mapping of run-sequence to orchestrator for complex builds

    @method execute
    @api public

    .020 s added

  ###
  Norma.execute = require "./utilities/orchestration"


  ###

    ready

    Ensures all dependencies for running are ready

    @method ready
    @api public

    .055 s added

  ###
  Norma.ready = require "./utilities/manage-dependencies"


  ###

    ready

    Ensures all dependencies for running are ready

    @method getPackages
    @api public

    .080 s added

  ###
  Norma.getPackages = require "./utilities/register-packages"



  ###

    bind-modes

    A mapping of arguments (--flags), env properties (dev vs production)
    and settings from the user

    .024 s added

  ###
  require("./utilities/bind-modes")(Norma)

  ###

    method binding for all options in /methods

  ###
  methodDir = Path.join __dirname, "./methods/"
  methods = MapTree methodDir


  for method in methods.children by -1
    if not method.path
      continue

    name = Path.basename(method.name, Path.extname(method.name))
    Norma[name] = require("./#{Path.relative(__dirname, method.path)}")

  Norma.i = Norma.install

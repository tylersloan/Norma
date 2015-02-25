
Orchestrator  = require "orchestrator"
Inherits      = require "inherits"
Path          = require "path"
Home          = require "user-home"
Util          = require "util"
_             = require "underscore"
Fs            = require "fs"
Flags = require("minimist")( process.argv.slice(2) )


MkDir = require("./utilities/directory-tools").mkdir
# ManageDependencies = require "./utilities/manage-dependencies"
# RegisterPackages = require "./utilities/register-packages"


# PROTOTYPE ---------------------------------------------------------
Norma = ->

  self = @

  # Home directory for storage of globals and scaffolds
  if Home
    homePath = Path.resolve Home, "norma"
  else
    homePath = Path.resolve __dirname, "../../norma"

  if !Fs.existsSync homePath
    MkDir homePath

  # self.setOptions = (options) ->

  # Private variables
  # self._ = _.defaults(
  #   options or {},
  #   cwd: process.cwd()
  #   userHome: homePath
  #   prefix: "Ø "
  # )
  self._ =
    cwd: process.cwd()
    userHome: homePath
    prefix: "Ø "

  self.args = Flags._

  self.packages = []

  self.watchStarted = false


  # Get the package.json for norma info
  self.version = require(Path.join __dirname, "../package.json").version



  Orchestrator.call self
  return


###

  Existing methods from orchestrator:

  reset, add, task, hasTask, start, stop, sequence, allDone, onAll

###
Inherits Norma, Orchestrator


###

  The Norma constructor

  The exports of the norma module is an instance of this class.

  Example:

    Norma = require "norma"
    Norma_2 = new Norma.Norma()

  @method Norma
  @api public

###

Norma::Norma = Norma


###

  Subscribe Shorthand

  The binding of subscribe allows for syntatic sugar to event subscriptions

  Example:

    Norma.subscribe "watch-started", () ->
      console.log "watch has begun"

  @method subscribe
  @api public

###
Norma::subscribe = Norma::on
# Norma::emit = Norma::emit



###

  Prompt

  Version of readline interface for prompt during watch

  @method config
  @api public

###



# DEPRECATED
Norma::events =
  on: Util.deprecate Norma::on, "use Norma.on instead"
  emit: Util.deprecate Norma::emit, "use Norma.emit instead"
  listeners: Util.deprecate Norma::listeners, "use Norma.listeners instead"


norma = module.exports = new Norma

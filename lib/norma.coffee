
Orchestrator  = require "orchestrator"
Inherits      = require "inherits"
Path          = require "path"
Home          = require "user-home"
_             = require "underscore"
Fs            = require "fs"
Vfs           = require "vinyl-fs"


MkDir = require("./utilities/directory-tools").mkdir


# PROTOTYPE ---------------------------------------------------------
Norma = ->

  self = @

  # Home directory for storage of globals and scaffolds
  if Home
    homePath = Path.resolve Home, ".norma"
  else
    homePath = Path.resolve __dirname, "../../.norma"

  if !Fs.existsSync homePath
    MkDir homePath

  self._ =
    cwd: process.cwd()
    userHome: homePath
    prefix: "Ø "
    version: require(Path.join __dirname, "../package.json").version
    packageDirs: {}

  self.args = []

  self.packages = []

  self.watchStarted = false



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



# Shamelessly borrowed from gulp
Norma::src = Vfs.src
Norma::dest = Vfs.dest

module.exports = new Norma

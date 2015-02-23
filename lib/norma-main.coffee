
Orchestrator  = require "orchestrator"
Inherits      = require "inherits"
Path          = require "path"
Home          = require "user-home"
Util          = require "util"
_             = require "underscore"
Fs            = require "fs"

MapTree = require("./utilities/directory-tools").mapTree
MkDir = require("./utilities/directory-tools").mkdir
# ManageDependencies = require "./utilities/manage-dependencies"
# RegisterPackages = require "./utilities/register-packages"


# PROTOTYPE ---------------------------------------------------------
Norma = (options) ->

  self = @

  # Home directory for storage of globals and scaffolds
  if Home
    homePath = Path.resolve Home, "norma"
  else
    homePath = Path.resolve __dirname, "../../norma"

  if !Fs.existsSync homePath
    MkDir homePath

  # Private variables
  self._ = _.defaults(
    options or {},
    cwd: process.cwd()
    userHome: homePath
    prefix: "Ø "
  )

  self.packages = []


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

  @method prompt
  @api public

###
# Norma::prompt = require("./utilities/prompt")(Norma)


###

  Prompt

  Version of readline interface for prompt during watch

  @method config
  @api public

###
# Norma.config = new require("./utilities/read-config")
workbench = require("./utilities/test")

console.log workbench.toString()
Norma::workbench = ->
  console.log "foobar"


# DEPRECATED
# Norma::events =
#   on: Util.deprecate Norma::on, "use Norma.on instead"
#   emit: Util.deprecate Norma::emit, "use Norma.emit instead"
#   listeners: Util.deprecate Norma::listeners, "use Norma.listeners instead"
#
#
# Norma::log = require "./events/message"
# Norma::on "message", Norma::log
#
# Norma::Error = require "./events/error"
# Norma::on "error", Norma::Error
#
# Norma::Close = require "./events/error"

norma = module.exports = new Norma

  # new norma.Error err

# do ->
#   eventDir = Path.resolve __dirname, "./events/"
#   events = MapTree eventDir
#
#   for event in events.children
#     require(event.path) if event.path


# # LIBRARIES

# Norma.getSettings = require("./utilities/read-settings")(Norma)

# Norma.execute = require("./utilities/orchestration")(Norma)
#
#
#
# # STATES
# Norma.watchStarted = false
# require("./utilities/bind-modes")(Norma)
#
#
# # METHODS
#
# do ->
#   methodDir = Path.resolve __dirname, "./methods/"
#   methods = MapTree methodDir
#
#   for method in methods.children
#     name = Path.basename(method.name, Path.extname(method.name))
#
#     Norma[name] = require(method.path) if method.path
#
#
# Norma.ready = ManageDependencies
# Norma.getPackages = RegisterPackages
#
# Norma.run = (tasks, cwd) ->
#
#   if !tasks then tasks = Norma._
#   if !cwd then cwd = process.cwd()
#
#   # copy array for non destructive slicing
#   _tasks = tasks.slice()
#
#   # set default task to watch if running bare
#   if _tasks.length is 0
#     _tasks = ["watch"]
#
#   ###
#
#     This is where we need to register all packages prior
#     to running any tasks
#
#   ###
#   noPackageTasks = [
#     "config"
#     "create"
#     "help"
#     "init"
#     "install"
#     "open"
#     "remove"
#     "search"
#     "update"
#   ]
#
#
#   start = (_pgkes) ->
#
#     # Fire the start event
#     Norma.emit "start"
#
#     try
#       task = Norma[_tasks[0]]
#       action = _tasks.slice()
#       action.shift()
#
#       task action, cwd
#
#     catch e
#       pkge = _tasks.slice()
#       method = pkge[0]
#       pkge.shift()
#
#       if pkge.length
#         method += "-#{pkge[0]}"
#
#       if pkges[method]
#         pass = -> return
#         Norma.tasks[method].fn( pass, action, cwd)
#       else
#         e.level = "crash"
#         Norma.emit "error", e
#
#   # lookup packages if necessary
#   if noPackageTasks.indexOf(_tasks[0]) is -1
#
#     Norma.getPackages(cwd)
#       .then( (tasks) ->
#         start tasks
#       )
#
#   else start({})


# Norma.root = Path.resolve __dirname, "../../"

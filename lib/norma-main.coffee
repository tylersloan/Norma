
Orchestrator  = require("orchestrator")
Inherits      = require("inherits")
Path          = require "path"
Home          = require "user-home"

MapTree = require("./utilities/directory-tools").mapTree
MkDir = require("./utilities/directory-tools").mkdir
ManageDependencies = require "./utilities/manage-dependencies"
RegisterPackages = require "./utilities/register-packages"

# PROTOTYPE ---------------------------------------------------------

# TAKEN FROM GULP.JS WHICH IS AMAZING
_norma = ->
  Orchestrator.call this
  return

Inherits _norma, Orchestrator

# _norma::task = _norma::add
###

  Existing methods from orchestrator:

  reset
  add
  task
  hasTask
  start
  stop
  sequence
  allDone
  _resetTask
  _resetAllTasks
  _resetSpecificTasks
  _runStep
  _readyToRunTask
  _stopTask
  _emitTaskDone
  _runTask
  onAll

###

Norma = new _norma()

# This needs to be fixed!
GLOBAL.Norma = Norma


# NORMA -------------------------------------------------------------

# STORAGE
Norma.packages = []
Norma.prefix = "Ø "
if Home
  MkDir Path.resolve Home, "norma"
  Norma.userHome = Path.resolve Home, "norma"
else
  MkDir Path.resolve __dirname, "../../norma"
  Norma.userHome = Path.resolve __dirname, "../../norma"

# Get the package.json for norma info
Norma.version = require(Path.join __dirname, "../package.json").version


# EVENTS
Norma.subscribe = (evt, cb) ->
  Norma.on evt, cb

# DEPRECATED
Norma.events =
  on: Norma.on
  emit: Norma.emit
  listeners: Norma.listeners


do ->
  eventDir = Path.resolve __dirname, "./events/"
  events = MapTree eventDir

  for event in events.children
    require(event.path)(Norma) if event.path


# LIBRARIES
Norma.config = require "./utilities/read-config"
Norma.getSettings = require "./utilities/read-settings"
Norma.prompt = require "./utilities/prompt"
Norma.execute = require "./utilities/orchestration"



# STATES
Norma.watchStarted = false
require("./utilities/bind-modes")(Norma)


# METHODS

do ->
  methodDir = Path.resolve __dirname, "./methods/"
  methods = MapTree methodDir

  for method in methods.children
    name = Path.basename(method.name, Path.extname(method.name))

    Norma[name] = require(method.path) if method.path


Norma.ready = ManageDependencies
Norma.getPackages = RegisterPackages

Norma.run = (tasks, cwd) ->

  if !tasks then tasks = Norma._
  if !cwd then cwd = process.cwd()

  # copy array for non destructive slicing
  _tasks = tasks.slice()

  # set default task to watch if running bare
  if _tasks.length is 0
    _tasks = ["watch"]

  ###

    This is where we need to register all packages prior
    to running any tasks

  ###
  noPackageTasks = [
    "add"
    "config"
    "create"
    "help"
    "init"
    "open"
    "remove"
    "search"
    "update"
  ]


  start = (_pgkes) ->

    # Fire the start event
    Norma.emit "start"

    try
      task = Norma[_tasks[0]]
      action = _tasks.slice()
      action.shift()

      task action, cwd

    catch e
      pkge = _tasks.slice()
      method = pkge[0]
      pkge.shift()

      if pkge.length
        method += "-#{pkge[0]}"

      if pkges[method]
        pass = -> return
        Norma.tasks[method].fn( pass, action, cwd)
      else
        e.level = "crash"
        Norma.emit "error", e

  # lookup packages if necessary
  if noPackageTasks.indexOf(_tasks[0]) is -1

    Norma.getPackages(cwd)
      .then( (tasks) ->
        start tasks
      )

  else start({})


# Norma.root = Path.resolve __dirname, "../../"


module.exports = Norma

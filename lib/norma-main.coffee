
Orchestrator  = require("orchestrator")
Inherits      = require("inherits")
EventEmitter  = new (require("events").EventEmitter)
Path          = require "path"
Domain        = require("domain").create();
Home          = require "user-home"


MapTree = require("./utilities/directory-tools").mapTree
MkDir = require("./utilities/directory-tools").mkdir

# PROTOTYPE ---------------------------------------------------------

# TAKEN FROM GULP.JS WHICH IS AMAZING
_norma = ->
  Orchestrator.call this
  return

Inherits _norma, Orchestrator


_norma::task = _norma::add
_norma::events = EventEmitter


Norma = new _norma()

# This needs to be fixed!
GLOBAL.Norma = Norma



# NORMA -------------------------------------------------------------

# STORAGE
Norma.packages = []


if Home
  MkDir Path.resolve Home, "norma"
  Norma.userHome = Path.resolve Home, "norma"
else
  MkDir Path.resolve __dirname, "../../norma"
  Norma.userHome = Path.resolve __dirname, "../../norma"


# LIBRARIES
Norma.domain = Domain
Norma.config = require "./utilities/read-config"
Norma.settings = require "./utilities/read-settings"
Norma.prompt = require "./utilities/prompt"
Norma.prefix = "Ø "


# EVENTS
Norma.subscribe = (evt, cb) ->
  Norma.events.on evt, cb

Norma.emit = (evt, obj) ->
  Norma.events.emit evt, obj

do ->
  eventDir = Path.resolve __dirname, "./events/"
  events = MapTree eventDir

  for event in events.children
    require(event.path)(Norma) if event.path



# STATES
Norma.watchStarted = false
require("./utilities/bind-modes")(Norma)


# METHODS
Norma.method = {}

do ->
  methodDir = Path.resolve __dirname, "./methods/"
  methods = MapTree methodDir

  for method in methods.children
    name = Path.basename(method.name, Path.extname(method.name))

    Norma.method[name] = require(method.path) if method.path

# Norma.root = Path.resolve __dirname, "../../"










Norma.launch = require "./utilities/launcher"

module.exports = Norma

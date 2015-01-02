Path = require "path"
Fs = require "fs"
Semver = require "semver"
Npm = require "npm"
Q = require "kew"

MapTree = require("./directory-tools").mapTree

module.exports = (tasks, cwd) ->

  # create the deferred
  loaded = Q.defer()


  node_modules = Path.resolve cwd, "node_modules"
  config = Path.resolve cwd, "package.json"

  if !config
    loaded.resolve("ok")
    return loaded

  installed = MapTree node_modules, true

  scope = [
    "dependencies"
    "devDependencies"
    "peerDependencies"
  ]


  config = require config

  added = {}
  alreadyInstalled = {}


  # ADDED -------------------------------------------------------------------

  for type in scope
    for key of config[type]
      added[key] = config[type][key]



  # INSTALLED ---------------------------------------------------------------

  getPkgeDetails = (pkge) ->

    pkgeConfig = require pkge.path

    alreadyInstalled[pkgeConfig.name] = pkgeConfig.version


  for existing in installed.children
    if !existing.children
      continue

    for child in existing.children
      if child.name is "package.json"
        getPkgeDetails child



  # COMPARE -----------------------------------------------------------------


  installs = []

  npmLoaded = false

  loadNPM = (cb) ->

    if npmLoaded
      cb()
      return

    npmReady = Q.defer()

    Npm.load npmReady.makeNodeResolver()

    npmReady.promise.then( ->

      npmLoaded = false
      cb()
    )

  for addedName of added

    update = (name, message) ->

      Norma.events.emit "message", message

      obj = {}

      obj[name] = Q.defer()

      install = ->
        Npm.commands.install [name], obj[name].makeNodeResolver()

      loadNPM install

      installs.push obj[name]


    if alreadyInstalled[addedName]
      # git url
      if added[addedName].match /\//g
        continue

      if !Semver.satisfies alreadyInstalled[addedName], added[addedName]

        message =
          name: addedName
          message: "needs updating"

        update addedName, message

    else
      message =
        name: addedName
        message: "needs installing"

      update addedName, message


  Q.all(installs)
    .then( ->
      loaded.resolve("ok")
    )

  return loaded

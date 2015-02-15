Path = require "path"
Fs = require "fs"
Semver = require "semver"
Npm = require "npm"
Q = require "kew"
_ = require "underscore"

MapTree = require("./directory-tools").mapTree

module.exports = (tasks, cwd) ->

  # create the deferred
  loaded = Q.defer()

  update = Norma.settings.get("autoUpdate")

  if update is "false" or update is false
    loaded.resolve("ok")
    return loaded

  node_modules = Path.resolve cwd, "node_modules"
  config = Path.resolve cwd, "package.json"

  if !Fs.existsSync config
    loaded.resolve("ok")
    return loaded


  installed = MapTree node_modules, true

  scope = [
    "dependencies"
    "devDependencies"
    "peerDependencies"
  ]


  # compare with global packages
  globalConfig = Path.join Norma.userHome, "packages", "package.json"

  if Fs.existsSync globalConfig
    globalConfig = require globalConfig
  else
    globalConfig = false


  # local
  config = require config

  if globalConfig
    globalAlreadyInstalled = {}
    global_modules = Path.join Norma.userHome, "packages", "node_modules"
    globalInstalled = MapTree global_modules, true

    getGlobalPkgeDetails = (pkge) ->

      pkgeConfig = require pkge.path

      globalAlreadyInstalled[pkgeConfig.name] = pkgeConfig.version


    for existing in globalInstalled.children
      if !existing.children
        continue

      for child in existing.children
        if child.name is "package.json"
          getGlobalPkgeDetails child

    for type in scope
      if config[type] and globalConfig[type]
        for pkge of config[type]

          if !globalAlreadyInstalled[pkge] or !config[type][pkge]
            continue

          # local is same as global
          if Semver.satisfies(globalAlreadyInstalled[pkge], config[type][pkge])
            delete config[type][pkge]
            continue

          if Semver.ltr globalAlreadyInstalled[pkge], config[type][pkge]
            Norma.emit(
              "message"
              "your global version of #{pkge} can be updated"
            )
            continue

          if Semver.gtr globalAlreadyInstalled[pkge], config[type][pkge]
            Norma.emit(
              "message"
              "your local version of #{pkge} can be updated"
            )
            continue


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
          message: "#{addedName} needs updating"

        update addedName, message

    else
      message =
        name: addedName
        message: "#{addedName} needs installing"

      update addedName, message


  Q.all(installs)
    .then( ->
      loaded.resolve("ok")
    )

  return loaded

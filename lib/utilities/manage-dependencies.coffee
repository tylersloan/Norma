Path = require "path"
Fs = require "fs"

Q = require "kew"
_ = require "underscore"




module.exports = (tasks, cwd, flush) ->

  Semver = require "semver"



  Norma = require "./../norma"
  Spawn = require "./promise-spawn"
  MapTree = require("./directory-tools").mapTree
  Cache = require "./cache"

  # create the deferred
  loaded = Q.defer()

  if !cwd then cwd = process.cwd()

  cacheDir = Path.join Norma._.userHome, "packages"
  node_modules = Path.resolve cwd, "node_modules"
  config = Path.resolve cwd, "package.json"

  if !Fs.existsSync config
    loaded.resolve("ok")
    return loaded


  installed = MapTree node_modules, true
  cached = MapTree cacheDir

  scope = [
    "dependencies"
    "peerDependencies"
  ]

  if not process.env.CI and not Norma.production
    scope.push "devDependencies"


  # compare with global packages
  globalConfig = Path.join Norma._.userHome, "packages", "package.json"

  if Fs.existsSync globalConfig
    globalConfig = require globalConfig
  else
    globalConfig = false


  # local
  config = JSON.parse Fs.readFileSync(config, encoding: "utf8")

  if globalConfig
    globalAlreadyInstalled = {}
    global_modules = Path.join Norma._.userHome, "packages", "node_modules"
    globalInstalled = MapTree global_modules, true

    getGlobalPkgeDetails = (pkge) ->

      pkgeConfig = JSON.parse Fs.readFileSync(pkge.path, encoding: "utf8")

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

          if config[type][pkge].match /git/
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

    pkgeConfig = JSON.parse Fs.readFileSync(pkge.path, encoding: "utf8")

    alreadyInstalled[pkgeConfig.name] = pkgeConfig.version


  for existing in installed.children
    if !existing.children
      continue

    for child in existing.children
      if child.name is "package.json"
        getPkgeDetails child



  # COMPARE -----------------------------------------------------------------


  installs = []
  list = []
  for addedName of added

    update = (name, message) ->

      Norma.emit "message", message

      obj = {}

      obj[name] = Spawn("npm", ["i", name], cwd)
      list.push name.split("@")[0]
      # Exec("npm i #{name}", {cwd: cwd}, obj[name].makeNodeResolver())
      installs.push obj[name]


    if alreadyInstalled[addedName]
      # git url
      if added[addedName].match /\//g
        continue

      if !Semver.satisfies alreadyInstalled[addedName], added[addedName]

        message =
          name: addedName
          message: "Updating #{addedName}@#{added[addedName]}..."

        update "#{addedName}@#{added[addedName]}", message

    else
      isCached = false
      for cachedPkge in cached.children
        if not added[cachedPkge.name]
          continue

        # looking at the right cached package
        versions = cachedPkge.children?.map( (pkge) ->
          return pkge.name
        )

        validVersion = Semver.maxSatisfying versions, added[addedName]
        if validVersion
          isCached = true

      if not isCached
        message =
          name: addedName
          message: "Installing #{addedName}@#{added[addedName]}..."

        update "#{addedName}@#{added[addedName]}", message


  Q.all(installs)
    .then( ->
      if list.length
        Cache list.join(" "), ->
          loaded.resolve("ok")
      else
        loaded.resolve("ok")
    )

  return loaded


Path = require "path"
Fs = require "fs"
Multimatch = require "multimatch"
_ = require "underscore"

Norma = require "./../norma"
MapTree = require("./directory-tools").mapTree



module.exports = (cwd, targetCwd) ->

  cwd or= process.cwd()
  normaConfig = Norma.config(cwd)


  packageList = new Array
  packages = new Array


  # Load package and see if it has any task
  mapPkge = (pkgeCwd, name) ->

    name = name.split("norma-")[1]

    # short variable assignment
    n = normaConfig

    # found in the tasks object
    if (n.tasks and n.tasks[name]) or (n.test and n.test[name])

      # don't load dev packages in production
      # if n.tasks[name]?.dev and Norma.production
      #   return


      # store load path for future calls via extension
      if !Norma._.packageDirs[name]
        Norma._.packageDirs[name] = pkgeCwd
      try
        # load package
        task = require pkgeCwd

        # push task to packages
        if typeof task is "function"
          # copy settings to be sent
          normaConfig = JSON.parse JSON.stringify(normaConfig)
          taskObject = task normaConfig, name
          taskObject = null

          packages.push task.tasks
      catch err
        err.message = "At #{pkgeCwd}: #{err.message}"
        err.level = "crash"
        Norma.emit "error", err

    return



  # Loop through file structure to find packages
  checkFile = (file) ->

    # depreciation support
    if file.name is "norma.json" or file.name is "norma.cson" or file.name is "Norma"
      pkgeConfig = Norma.config Path.resolve file.path, "../"

      if pkgeConfig.type is "package" and pkgeConfig.main
        entry = Path.resolve file.path, "../", pkgeConfig.main

        Norma.packages.push pkgeConfig.name
        Norma.packages = _.uniq Norma.packages

        mapPkge entry, pkgeConfig.name

    else if file.children

      for nestedFile in file.children

        checkFile nestedFile


  # Norma-packages (non npm based)
  if Fs.existsSync Path.join( cwd, "norma-packages")

      customs = MapTree Path.join( cwd, "norma-packages")

      checkFile pkge for pkge in customs.children


  # Package testing (used in building and testing packages)
  if normaConfig.type is "package"

    # verify we aren't in root
    if cwd isnt Path.resolve Norma._.userHome, 'packages'

      pkges = MapTree process.cwd()

      checkFile pkges



  # npm package testing
  pattern = [
    "norma-*"
    "norma.*"
  ]


  config = Path.resolve cwd, "package.json"

  node_modules = Path.resolve cwd, "node_modules"



  scope = [
    "dependencies"
    "peerDependencies"
  ]

  if not process.env.CI and not Norma.production
    scope.push "devDependencies"

  replaceString = /^norma(-|\.)/

  joinedPackages = {}



  if Fs.existsSync(config) and Fs.existsSync(node_modules)


    # Using the require method keeps the same in memory, instead we use
    # a synchronous fileread of the JSON.
    config = Fs.readFileSync config, encoding: "utf8"


    try
      config = JSON.parse(config)
    catch err
      err.level = "crash"

      Norma.emit "error", err


    names = scope.reduce(
      (result, prop) ->

        result.concat Object.keys(config[prop] or {})
      []
    )


    Multimatch(names, pattern).forEach (name) ->

      if Norma.packages.indexOf(name) > -1
        return

      requirePath = Path.resolve node_modules, name

      if not Fs.existsSync requirePath
        return

      Norma.packages.push name
      Norma.packages = _.uniq Norma.packages

      _obj = {}
      _obj[name] = Path.resolve(requirePath)

      packageList.push _obj


      return


    for pkge in packageList
      key = Object.keys(pkge)[0]
      mapPkge pkge[key], key



  ###

    to load a task from cache we need to know a few things

    1. what tasks do we need to load
      - this is found by looking at config files
    2. if there is a set version
      - if there is version added in package.json
    3. else load the latest version

  ###
  cacheDir = Path.join Norma._.userHome, "packages"
  cached = MapTree cacheDir
  Semver = require "semver"

  for cachedPkge in cached.children

    # short variable assignment
    n = normaConfig
    name = cachedPkge.name.replace("norma-", "")

    if Norma.packages.indexOf(cachedPkge.name) > -1
      continue

    if not n
      break

    # found in the tasks or test object
    if (n.tasks and n.tasks[name]) or (n.test and n.test[name])

      # lookup latest
      versions = cachedPkge.children?.map( (pkge) ->
        return pkge.name
      )
      versions.sort Semver.compare

      installHighest = ->
        highestVersion = versions[0]

        for version in cachedPkge.children
          if version.name is highestVersion
            highestVersion = version
            break

        if highestVersion.path
          Norma.packages.push cachedPkge.name
          Norma.packages = _.uniq Norma.packages
          mapPkge highestVersion.path, cachedPkge.name


      if not Fs.existsSync(config)
        installHighest()
      else
        # Using the require method keeps the same in memory, instead we use
        # a synchronous fileread of the JSON.
        configFile = Fs.readFileSync config, encoding: "utf8"
        configFile = JSON.parse(configFile)
        for _scope in scope
          if not configFile[_scope]?[cachedPkge.name]
            installHighest()
            break

          specifiedVersion = configFile[_scope][cachedPkge.name]
          validVersion = Semver.maxSatisfying versions, specifiedVersion

          if validVersion
            for version in cachedPkge.children
              if version.name is validVersion
                validVersion = version
                break

            if validVersion.path
              Norma.packages.push cachedPkge.name
              Norma.packages = _.uniq Norma.packages
              mapPkge validVersion.path, cachedPkge.name

            break



  packages = _.uniq packages
  return packages

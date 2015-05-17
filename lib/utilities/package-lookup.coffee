
Path = require "path"
Fs = require "fs"
Multimatch = require "multimatch"
_ = require "underscore"

Norma = require "./../norma"
MapTree = require("./directory-tools").mapTree



module.exports = (cwd, targetCwd) ->

  if !cwd then cwd = process.cwd()

  if targetCwd
    # Get config for task comparison
    normaConfig = Norma.config(targetCwd)
  else
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

      localInstall = Path.resolve node_modules, "#{name}"

      if not Fs.existsSync localInstall
        return

      Norma.packages.push name
      Norma.packages = _.uniq Norma.packages

      _obj = {}
      _obj[name] = Path.resolve(node_modules, name)

      packageList.push _obj


      return


    for pkge in packageList
      key = Object.keys(pkge)[0]
      mapPkge pkge[key], key


  return packages

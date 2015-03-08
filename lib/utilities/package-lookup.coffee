
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
  mapPkge = (pkgeCwd) ->

    try
      # load package
      task = require pkgeCwd

      # push task to packages
      if typeof task is "function"
        taskObject = task normaConfig
        taskObject = null

        packages.push task.tasks
    catch err
      console.log "At #{pkgeCwd}"
      err.level = "crash"
      Norma.emit "error", err
    #
    # else
    #   packages.push task




  # Loop through file structure to find packages
  checkFile = (file) ->

    if file.name is "norma.json"
      pkgeConfig = Norma.config Path.resolve file.path, "../"

      if pkgeConfig.type is "package" and pkgeConfig.main
        entry = Path.resolve file.path, "../", pkgeConfig.main


        Norma.packages.push pkgeConfig.name
        Norma.packages = _.uniq Norma.packages

        mapPkge entry

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
    "devDependencies"
    "peerDependencies"
  ]

  replaceString = /^norma(-|\.)/


  if Fs.existsSync(config) and Fs.existsSync(node_modules)

    # Using the require method keeps the same in memory, instead we use
    # a synchronous fileread of the JSON. This should probably be in a try
    # with a Norma error emitted on fail

    # TODO - wrap in try catch with error
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


      Norma.packages.push name
      Norma.packages = _.uniq Norma.packages

      packageList.push Path.resolve(node_modules, name)

      return


    for pkge in packageList

      packageList[pkge] = mapPkge pkge


  return packages

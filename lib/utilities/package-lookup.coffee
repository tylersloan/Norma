
Path = require "path"
Fs = require "fs"
Multimatch = require "multimatch"
_ = require "underscore"

MapTree = require("./directory-tools").mapTree



module.exports = (tasks, cwd) ->

  # Get config for task comparison
  normaConfig = Norma.config()
  packageList = new Array
  packages = new Array


  # Load package and see if it has any task
  mapPkge = (pkgeCwd) ->

    try
      # load package
      task = require pkgeCwd

      # push task to packages
      if typeof task is "function"
        taskObject = task normaConfig, tasks
        taskObject = null

        packages.push task.tasks
    catch err
      console.log "At #{pkgeCwd}"
      err.level = "crash"
      Norma.events.emit "error", err
    #
    # else
    #   packages.push task





  checkFile = (file) ->

    if file.name is "norma.json"
      pkgeConfig = Norma.config Path.resolve file.path, "../"

      if pkgeConfig.type is "package" and pkgeConfig.main
        entry = Path.resolve file.path, "../", pkgeConfig.main
        Norma.packages.push pkgeConfig.name
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
    if cwd isnt Path.resolve Norma.userHome, 'packages'

      pkges = MapTree process.cwd()

      checkFile pkges



  # npm package testing
  pattern = [
    "#{Tool}-*"
    "#{Tool}.*"
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

      Norma.events.emit "error", err


    names = scope.reduce(
      (result, prop) ->

        result.concat Object.keys(config[prop] or {})
      []
    )


    Multimatch(names, pattern).forEach (name) ->

      Norma.packages.push name

      packageList.push Path.resolve(node_modules, name)

      return


    for pkge in packageList

      packageList[pkge] = mapPkge pkge


  return packages

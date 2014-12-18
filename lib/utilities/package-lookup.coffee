
Path = require "path"
Fs = require "fs-extra"
Multimatch = require "multimatch"
Findup = require "findup-sync"

MapTree = require("./directory-tools").mapTree
ReadConfig = require "./read-config"


module.exports = (tasks, cwd) ->
  # throw new Error "hello"

  normaConfig = ReadConfig process.cwd()
  packageList = new Array
  packages = new Array


  mapPkge = (pkgeCwd) ->

    task = require pkgeCwd

    if typeof task is "function"
      taskObject = task normaConfig, Path.resolve(__dirname, '../../')
      taskObject = null

      packages.push task.tasks
    else
      packages.push task



  checkFile = (file) ->

    if file.name is "norma.json"
      pkgeConfig = ReadConfig Path.resolve file.path, "../"

      if pkgeConfig.type is "package" and pkgeConfig.main
        entry = Path.resolve file.path, "../", pkgeConfig.main

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
    if cwd isnt Path.resolve __dirname, '../../'
      pkges = MapTree process.cwd()

      checkFile pkges



  # npm package testing
  pattern = [
    "#{Tool}-*"
    "#{Tool}.*"
  ]


  config = Findup "package.json", cwd: cwd

  node_modules = Findup "node_modules", cwd: cwd

  scope = [
    "dependencies"
    "devDependencies"
    "peerDependencies"
  ]

  replaceString = /^norma(-|\.)/


  if config and node_modules

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

      packageList.push Path.resolve(node_modules, name)

      return

    for pkge in packageList
      packageList[pkge] = mapPkge pkge


  return packages

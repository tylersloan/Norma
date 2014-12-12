
Path = require "path"
Fs = require "fs-extra"
Multimatch = require "multimatch"
Findup = require "findup-sync"

MapTree = require("./directory-tools").mapTree
ReadConfig = require "./read-config"

arrayify = (el) ->
  (if Array.isArray(el) then el else [el])


camelize = (str) ->
  str.replace /-(\w)/g, (m, p1) ->
    p1.toUpperCase()



module.exports = (tasks, cwd, type) ->


  normaConfig = ReadConfig process.cwd()
  packageList = new Array
  packages = new Array


  mapPkge = (pkgeCwd) ->

    task = require pkgeCwd

    taskObject = task normaConfig, Path.resolve(__dirname, '../../')
    taskObject = null

    packages.push task.tasks



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
  pattern = arrayify([
    "#{Tool}-*"
    "#{Tool}.*"
  ])

  config = Findup "package.json", cwd: cwd

  node_modules = Findup "node_modules", cwd: cwd

  scope = arrayify([
    "dependencies"
    "devDependencies"
    "peerDependencies"
  ])

  replaceString = /^norma(-|\.)/



  if config and node_modules
    # console.log(
    #   Chalk.red("Could not find dependencies." +
    #   " Do you have a package.json file in your project?"
    #   )
    # )
    #
    config = require(config)

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

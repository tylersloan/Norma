
Path = require "path"
Fs = require "fs"
_ = require "underscore"
Q = require "kew"

Norma = require "./../norma"
PkgeLookup = require "./package-lookup"
AutoDiscover = require "./auto-discover"


module.exports = (cwd) ->

  loadedPackages = Q.defer()


  if !cwd then cwd = process.cwd()

  # Get any project specific packages (from package.json)
  projectTasks = PkgeLookup cwd

  # Get global packages added to Norma
  rootTasks = PkgeLookup (Path.resolve Norma._.userHome, "packages"), cwd

  combinedTasks = projectTasks.concat rootTasks


  # Combine all tasks list in order of local - local npm - global npm
  for task in combinedTasks
    # ensure it has all needed attributes
    for name of task
      # dep
      if !task[name].dep then task[name].dep = []

    _.extend Norma.tasks, task


  # see if we need to download any packages
  isMissingTasks = AutoDiscover(cwd, Norma.tasks, loadedPackages)

  ###

    Package extensions using the API as follows

    tasks: {
      "copy": {
        "src": "./raw",
        "dest": "./out"
      },
      "images": {
        "@extend": "copy"
        "src": "./second-raw",
        "dest": "./out"
      }
    }

  ###

  if !isMissingTasks

    config = Norma.config cwd

    for key of config.tasks

      # @extend "package" handling
      if config.tasks[key]["@extend"]
        extensionName =  key
        extension = config.tasks[key]["@extend"]

      # extended task does exist
      if !Norma.tasks[extension]
        continue

      extendedTask = require Norma._.pacakgeDirs[extension]

      # we handle merging of master to extension here
      config.tasks[extensionName] = _.extend(
        config.tasks[extension]
        config.tasks[extensionName]
      )

      # copy settings to be sent
      config = JSON.parse JSON.stringify(config)
      taskObject = extendedTask config, extensionName



    loadedPackages.resolve Norma.tasks

  return loadedPackages

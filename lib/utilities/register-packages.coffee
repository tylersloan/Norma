
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

    mergeExtendedTask = (key, object) ->

      # @extend "package" handling
      if object[key]["@extend"]
        extensionName = key
        extension = object[key]["@extend"]

      # extended task does exist
      if !Norma.tasks[extension]
        return


      extendedTask = require Norma._.packageDirs[extension]

      # we handle merging of master to extension here
      object[extensionName] = _.extend(
        config.tasks[extension]
        object[extensionName]
      )


      # copy settings to be sent
      config = JSON.parse JSON.stringify(config)
      taskObject = extendedTask config, extensionName

      return


    for key of config.tasks
      mergeExtendedTask key, config.tasks


    if _.isObject config.test

      for _test of config.test

        if _test is "before" or _test is "after"
          continue

        if _test is "main"

          if _.isArray config.test.main
            for item in config.test.main
              mergeExtendedTask item, config.test.main

            return

        mergeExtendedTask _test, config.test



    loadedPackages.resolve Norma.tasks

  return loadedPackages

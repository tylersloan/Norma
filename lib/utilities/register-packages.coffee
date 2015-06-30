
Path = require "path"
Fs = require "fs"
_ = require "underscore"
Q = require "kew"



module.exports = (cwd) ->
  Norma = require "./../norma"
  PkgeLookup = require "./package-lookup"
  AutoDiscover = require "./auto-discover"


  loadedPackages = Q.defer()

  cwd or= process.cwd()

  # Get global, local, and settings packages already installed
  rootTasks = PkgeLookup Path.resolve(Norma._.userHome)
  projectTasks = PkgeLookup cwd

  settingsTasks = []
  if Fs.existsSync Path.join(cwd, ".norma")
    settingsTasks = PkgeLookup Path.join(cwd, ".norma")


  combinedTasks = settingsTasks.concat projectTasks, rootTasks




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

  if isMissingTasks
    return loadedPackages


  config = Norma.config cwd

  # merge in settings
  settings = Norma.config Path.join(cwd, ".norma")
  config.tasks = _.extend config.tasks, settings.tasks
  config.test = _.extend config.test, settings.test

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

      if _test is "main" and  _.isArray config.test.main
        for item in config.test.main
          mergeExtendedTask item, config.test.main

        return

      mergeExtendedTask _test, config.test



  loadedPackages.resolve Norma.tasks

  return loadedPackages

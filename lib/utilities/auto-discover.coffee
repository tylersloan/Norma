
Chalk = require "chalk"
_ = require "underscore"

ReadConfig = require "./read-config"
PkgeLookup = require "./package-lookup"
Add = require "./../methods/add"
Build = require "./../methods/build"


module.exports = (cwd, tasks) ->

  config = ReadConfig cwd

  neededPackages = ["norma"]
  newPackages = []
  taskList = {}

  for key of config.tasks
    if tasks[key] is undefined
      neededPackages.push key

  foo = require("./../methods/build")

  build = ->
    foo tasks, cwd

  Add neededPackages, cwd, build

  if neededPackages.length > 1
    packages = neededPackages
    packages.shift()
    console.log(
      Chalk.green(
        "Installing the following packages:"
      )
      Chalk.magenta "#{packages.join(', ')}"
    )

    return true

  return false

  # # Get any project specific packages (from package.json)
  # projectTasks = PkgeLookup tasks, cwd
  #
  # # combine into object for easy access
  # for task in projectTasks
  #   _.extend taskList, task
  #
  # console.log neededPackages
  # # remove norma from packages array
  # neededPackages.shift()
  #
  # # remove all but new tasks to be merged in
  # for neededTask in neededPackages
  #   if taskList[neededTask]
  #     newPackages.push taskList[neededTask]


  # return newPackages


Path = require "path"
Fs = require "fs"
_ = require "underscore"

PkgeLookup = require "./package-lookup"
AutoDiscover = require "./auto-discover"


module.exports = (tasks, cwd) ->

  # Get any project specific packages (from package.json)
  projectTasks = PkgeLookup tasks, cwd


  # Get global packages added to Norma
  rootTasks = PkgeLookup tasks, (Path.resolve Norma.userHome, "packages")


  combinedTasks = projectTasks.concat rootTasks


  # Combine all tasks list in order of local - local npm - global npm
  for task in combinedTasks
    # ensure it has all needed attributes
    for name of task
      # dep
      if !task[name].dep then task[name].dep = []

    _.extend Norma.tasks, task

  # see if we need to download any packages
  isMissingTasks = AutoDiscover tasks, cwd, Norma.tasks


  return false if isMissingTasks

  return Norma.tasks

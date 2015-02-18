
Path = require "path"
Fs = require "fs"
_ = require "underscore"
Q = require "kew"

PkgeLookup = require "./package-lookup"
AutoDiscover = require "./auto-discover"


module.exports = (cwd) ->

  loadedPackages = Q.defer()


  if !cwd then cwd = process.cwd()

  # Get any project specific packages (from package.json)
  projectTasks = PkgeLookup cwd

  # Get global packages added to Norma
  rootTasks = PkgeLookup (Path.resolve Norma.userHome, "packages"), cwd

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


  if !isMissingTasks
    loadedPackages.resolve Norma.tasks

  return loadedPackages

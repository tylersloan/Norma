
Path = require "path"
Gulp = require "gulp"
Fs = require "fs-extra"
_ = require "underscore"

PkgeLookup = require "./package-lookup"
AutoDiscover = require "./auto-discover"


module.exports = (tasks, cwd) ->

  # Get any project specific packages (from package.json)
  projectTasks = PkgeLookup tasks, cwd

  # Get global packages added to Norma

  rootGulpTasks = PkgeLookup tasks, (Path.resolve __dirname, "../../")

  # # See if there are any project packages (from norma-packages dir)
  # # Should this check be in the PgkeLookup file?
  # customPackages = Fs.existsSync Path.join(cwd, "#{Tool}-packages")
  #
  # if customPackages
  #
  #   # Look for project specific packages (from norma-packages dir)
  #   customPackages = PkgeLookup tasks, Path.join(cwd, "#{Tool}-packages")
  #
  #   projectTasks = customPackages.concat projectTasks


  combinedTasks = projectTasks.concat rootGulpTasks

  # Combine all tasks list in order of local - local npm - global npm
  for task in combinedTasks
    _.extend Gulp.tasks, task


  # see if we need to download any packages
  isMissingTasks = AutoDiscover tasks, cwd, Gulp.tasks

  return false if isMissingTasks

  return true

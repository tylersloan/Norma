
Path = require "path"
Fs = require "fs-extra"
Sequence = require "run-sequence"
Chalk = require "chalk"
_ = require "underscore"
Gulp = require "gulp"

ReadConfig = require "./../utilities/read-config"
PkgeLookup = require "./../utilities/package-lookup"




module.exports = (tasks, cwd) ->

  config = ReadConfig cwd

  # PACKAGES -------------------------------------------------------------

  # Get any project specific packages (from package.json)
  projectTasks = PkgeLookup tasks, cwd

  # Get global packages added to Norma
  rootGulpTasks = PkgeLookup tasks, (Path.resolve __dirname, "../../")

  # See if there are any project packages (from norma-packages dir)
  # Should this check be in the PgkeLookup file?
  customPackages = Fs.existsSync Path.join(cwd, "#{Tool}-packages")

  if customPackages

    # Look for project specific packages (from norma-packages dir)
    customPackages = PkgeLookup tasks, Path.join(cwd, "#{Tool}-packages")

    projectTasks = customPackages.concat projectTasks


  combinedTasks = projectTasks.concat rootGulpTasks

  # Combine all tasks list in order of local - local npm - global npm
  for task in combinedTasks
    _.extend Gulp.tasks, task

  # Store lr in Gulp to span files
  Norma.watchStarted = true

  if Norma.verbose
    console.log(
      Chalk.cyan "Watching files..."
    )

  # Dynamically generate watch tasks off of runnable tasks
  createWatch = (task) ->

    if Norma.debug
      console.log(
        Chalk.red( "Task: #{task.toUpperCase()} added to watch" )
      )

    src = if config[task]? then config[task].src else "./**/*/"

    taskName = task

    exts = (
      ext.replace(".", "") for ext in Gulp.tasks[task].ext
    )

    Gulp.watch("#{src}/*.{#{exts}}", (event) ->


      fileName = Path.basename event.path

      if Norma.verbose
        console.log(
          Chalk.cyan(taskName.toUpperCase())
          "saw"
          Chalk.magenta(fileName)
          "was #{event.type}"
        )

      if Norma.reloadTasks.length
        Sequence taskName, Norma.reloadTasks
      else
        Sequence taskName

    )

  for task of Gulp.tasks

    createWatch(task) if Gulp.tasks[task].ext?



# API ---------------------------------------------------------------------

module.exports.api = [
  {
    command: ""
    description: "watch for changes"
  }
  {
    command: "--open"
    description: "open your browser to site"
  }
  {
    command: "--editor"
    description: "open your editor to current project root"
  }
]

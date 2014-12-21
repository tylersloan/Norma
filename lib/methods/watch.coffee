
Path = require "path"
Fs = require "fs-extra"
Sequence = require "run-sequence"
Chalk = require "chalk"
_ = require "underscore"
Gulp = require "gulp"

ReadConfig = require "./../utilities/read-config"
PkgeLookup = require "./../utilities/package-lookup"
LocalTld = require "./../utilities/local-tld"


module.exports = (tasks, cwd) ->

  config = ReadConfig cwd


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

    src = if config.tasks[task]? then config.tasks[task].src else "./**/*/"

    taskName = task

    exts = (
      ext.replace(".", "") for ext in Gulp.tasks[task].ext
    )

    Gulp.watch(
      [
        "#{src}/*.{#{exts}}"
        "!node_modules/**/*"
        "!.git/**/*"
      ], (event) ->


        fileName = Path.basename event.path

        if Norma.verbose
          console.log(
            Chalk.cyan(taskName.toUpperCase())
            "saw"
            Chalk.magenta(fileName)
            "was #{event.type}"
          )

        event[task] = taskName

        Sequence taskName

        Norma.events.emit 'file-change', event

    )

  for task of Gulp.tasks
    createWatch(task) if Gulp.tasks[task].ext?


  Norma.events.emit 'watch-start'

  if config.server
    if config.server.host and config.server.port

      LocalTld.remove config.server.port
      LocalTld.add config.server.host, config.server.port



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

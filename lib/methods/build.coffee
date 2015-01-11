
Path = require "path"
Fs = require "fs"
Sequence = require "run-sequence"
Chalk = require "chalk"
_ = require "underscore"
Gulp = require "gulp"

MapTree = require("./../utilities/directory-tools").mapTree
ReadConfig = require "./../utilities/read-config"
ExecCommand = require "./../utilities/execute-command"
GenerateTaskList = require "./../utilities/generate-task-list"



module.exports = (tasks, cwd) ->

  # Load config
  config = ReadConfig process.cwd()

  # After task is done message
  completeMessage =
    level: "notify"
    message: "✔ Complete!"
    name: "Build"
    color: "green"



  # POST-BUILD ----------------------------------------------------------

  completeBuild = ->

    if config.scripts and config.scripts.custom
      ExecCommand(
        config.scripts.custom
        process.cwd()
      ,
        ->
          Norma.events.emit "message", completeMessage
          # Norma.stop()
      )

    else

      Norma.events.emit "message", completeMessage
      # Norma.stop()



  # BUILD ---------------------------------------------------------------
  build = (list)->

    Gulp.task "final", () ->

      completeBuild()


    list.push "final"

    Sequence.apply null, list



  # GENERATE-LIST --------------------------------------------------------

  if !tasks.length
    # create list from packages and build
    build GenerateTaskList(config, Gulp.tasks)

  else


    # USER-DEFINED  ------------------------------------------------------

    for task in tasks
      if !Gulp.tasks[task]
        msg =
          level: "crash"
          message: "#{task} is not a known package"

        Norma.emit "error", msg

        return

      if !Gulp.tasks[task].fn
        msg =
          level: "crash"
          message: "#{task} has no function to build"

        Norma.emit "error", msg

        return


    Gulp.task "final", () ->

      completeBuild()


    tasks.push "final"


    Sequence.apply null, tasks




# API ----------------------------------------------------------------------

module.exports.api = [
  {
    command: "<task-name>"
    description: "build single task"
  }
  {
    command: "<task-name> <task-name> <task-name>"
    description: "build multiple tasks"
  }
]

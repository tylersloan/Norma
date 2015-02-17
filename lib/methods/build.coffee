
Path = require "path"
Fs = require "fs"
Chalk = require "chalk"
_ = require "underscore"

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
          Norma.emit "message", completeMessage
          # Norma.close()
      )

    else

      Norma.emit "message", completeMessage
      # Norma.close()



  # BUILD ---------------------------------------------------------------
  build = (list) ->

    Norma.task "final", () ->

      completeBuild()


    list.push "final"

    Norma.execute.apply null, list



  # GENERATE-LIST --------------------------------------------------------

  if !tasks.length
    # create list from packages and build
    build GenerateTaskList(config, Norma.tasks)

  else


    # USER-DEFINED  ------------------------------------------------------

    for task in tasks
      if !Norma.tasks[task]
        msg =
          level: "crash"
          message: "#{task} is not a known package"

        Norma.emit "error", msg

        return

      if !Norma.tasks[task].fn
        msg =
          level: "crash"
          message: "#{task} has no function to build"

        Norma.emit "error", msg

        return

    build tasks




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

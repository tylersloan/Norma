
Path = require "path"
Fs = require "fs"
Chalk = require "chalk"
_ = require "underscore"
Q = require "kew"

Norma = require "./../norma"
MapTree = require("./../utilities/directory-tools").mapTree
ReadConfig = require "./../utilities/read-config"
ExecCommand = require "./../utilities/execute-command"
GenerateTaskList = require "./../utilities/generate-task-list"



module.exports = (tasks, cwd) ->

  buildStatus = Q.defer()

  if !cwd then cwd = process.cwd()

  if !Fs.existsSync Path.join(cwd, "norma.json")
    buildStatus.reject("no norma.json found at #{cwd}")
    return buildStatus

  # Load config
  config = ReadConfig cwd

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
        cwd
      ,
        ->
          Norma.emit "message", completeMessage

          buildStatus.resolve "ok"
          # Norma.close()
      )

    else

      Norma.emit "message", completeMessage
      buildStatus.resolve "ok"
      # Norma.close()



  # BUILD ---------------------------------------------------------------
  build = (list) ->

    Norma.task "final", () ->

      completeBuild()


    list.push "final"


    try
      Norma.execute.apply null, list
    catch e
      buildStatus.reject e
      return buildStatus



  # GENERATE-LIST --------------------------------------------------------

  if !tasks.length

    try
      # create list from packages and build
      build GenerateTaskList(config, Norma.tasks)

    catch e
      buildStatus.reject e
      return buildStatus

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
    console.log tasks
    build tasks


  return buildStatus




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

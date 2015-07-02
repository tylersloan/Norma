
Path = require "path"
Fs = require "fs"
Chalk = require "chalk"
_ = require "underscore"
Q = require "kew"

Norma = require "./../norma"
MapTree = require("./../utilities/directory-tools").mapTree
ExecCommand = require "./../utilities/execute-command"
GenerateTaskList = require "./../utilities/generate-task-list"



module.exports = (tasks, cwd) ->

  buildStatus = Q.defer()

  if !cwd then cwd = process.cwd()


  # Load config
  config = Norma.config cwd
  localConfig = Norma.config(Path.join(cwd, ".norma"))

  # map tasks
  config.tasks = _.extend config.tasks, localConfig.tasks
  # map test
  config.test = _.extend config.test, localConfig.test



  if not config.tasks
    buildStatus.reject("No tasks configured in norma-file found at #{cwd}")
    return buildStatus

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
    isGroup = false
    # console.log tasks, Norma.tasks

    groupTasks = []
    for task, options of config.tasks

      if not options.group
        continue

      if typeof options.group is "string"
        options.group = [options.group]

      intersection = _.intersection tasks, options.group

      if intersection.length
        groupTasks.push task

    for task in tasks
      if not Norma.tasks[task] and not groupTasks.length

        msg =
          level: "crash"
          message: "#{task} is not a known package"

        Norma.emit "error", msg

        return

      if !Norma.tasks[task]?.fn and not groupTasks.length
        msg =
          level: "crash"
          message: "#{task} has no function to build"

        Norma.emit "error", msg

        return

    build GenerateTaskList(config, Norma.tasks, tasks.concat(groupTasks))


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

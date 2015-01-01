
Path = require "path"
Fs = require "fs-extra"
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

  # Set emtpy array for fileTypes
  fileTypes = new Array

  # After task is done message
  completeMessage =
    level: "notify"
    message: "✔ Complete!"
    name: "Build"
    color: "green"


  # CONFIG-FILE-TYPES ----------------------------------------------------

  ###

    Get types of files to be compiled based on items from the config
    This can return empty things

  ###
  do (config) ->

    task = config.tasks
    # Generate kind of files to compile
    for key of task

      if task[key].ext

        for ext in task[key].ext

          fileTypes.push( ext )




  # PROJECT-FILE-TYPES ---------------------------------------------------

  ###

    Get all of the file types within the project.
    This will determine what needs to be built

  ###
  ignore = config.ignore or []

  folders = MapTree Path.normalize(process.cwd()), ignore

  getFileTypes = (files) ->

    for child in files.children

      if child.type is "folder"
        getFileTypes(child)
      else
        ext = Path.extname(child.name)

        # add other file type to task list if not in config (autodiscovery)
        if fileTypes.indexOf(ext) is -1
          fileTypes.push(ext)

  getFileTypes folders



  # TASK-MANGEMENT ------------------------------------------------------

  buildList = (list) ->

    builtList = new Array

    for taskOrder of list
      for task of list[taskOrder]

        if !list[taskOrder][task].length
          continue

        # add each sync task for dynamic sequence running
        if task is "sync"
          for syncTask in list[taskOrder][task]
            builtList.push syncTask

        else
          builtList.push list[taskOrder][task]


    return builtList


  build = (list)->

    builtList = buildList(list)

    Gulp.task "final", () ->

      if config.scripts and config.scripts.custom
        ExecCommand(
          config.scripts.custom
          process.cwd()
        ,
          ->
            Norma.events.emit "message", completeMessage
        )

      else

        Norma.events.emit "message", completeMessage


    builtList.push "final"

    Sequence.apply null, builtList



  # GENERATE-LIST -------------------------------------------------------

  if !tasks.length
    GenerateTaskList(config, fileTypes, build)

  else


    # USER-DEFINED  -----------------------------------------------------

    for task in tasks
      if !Gulp.tasks[task]
        msg =
          color: "red"
          message: "#{task} is not a known package"

        Norma.events.emit "message", msg

        return

    Gulp.task "final", () ->

      if config.scripts and config.scripts.custom
        ExecCommand(
          config.scripts.custom
          process.cwd()
        ,
          ->
            Norma.events.emit "message", completeMessage
        )

      else

        Norma.events.emit "message", completeMessage


    tasks.push "final"


    # process.nextTick( ->
    Sequence.apply null, tasks
    # )



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


Path = require "path"
Fs = require "fs-extra"
Sequence = require "run-sequence"
Chalk = require "chalk"
_ = require "underscore"
Gulp = require "gulp"

MapTree = require("./../utilities/directory-tools").mapTree
ReadConfig = require "./../utilities/read-config"
ExecCommand = require "./../utilities/execute-command"




# TASKLIST --------------------------------------------------------------

generateTaskList = (types, cb) ->



  saveTask = (location, task) ->

    if location.indexOf(task) is -1
      location.push task


  ###

    @note

      Task are run in three phases, each with a sync run and an async
      run. The order is as follows:
        1. Pre Compile
        2. Main Compile
        3. Post compile.
      This taskList object is where those tasks are mapped. The type of
      taks is defined within each gulp task.

      An example of a full task set would be:
        1. Pre Compile - sync task would be starting a mongodb.
        2. Main Compile - actually compile the project
        3. Post Compile - start local project server
  ###
  taskList =
    pre :
      sync: []
      async: []
    main:
      sync: []
      async: []
    post:
      sync: []
      async: []

  ###

    The cyclomatic complexity of this statement is way too high.
    Need to break it apart into smaller, more efficent tasks.

  ###
  for task of Gulp.tasks

    if Gulp.tasks[task].ext

      for type in types

        if Gulp.tasks[task].ext.indexOf(type) > -1

          if Gulp.tasks[task].order

            Gulp.tasks[task].type = Gulp.tasks[task].type or "async"

            saveTask(
              taskList[Gulp.tasks[task].order][Gulp.tasks[task].type]
              task
            )

          else
            saveTask taskList.main.async, task


  cb taskList


###

  The through task is a way to run a full sequence even
  when sequence tasks aren"t defined. It feels kinda hacky but gulp
  isn"t really meant to be used in this way. When gulp moves to full
  orchestrator support, this tool will need a serious revist.

  @todo - Update to Gulp 4.0 and see what happens

###
Gulp.task "through", (cb) ->
  cb null



module.exports = (tasks, cwd) ->

  # Load config
  config = ReadConfig process.cwd()

  # Set emtpy array for fileTypes
  fileTypes = new Array


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

        if list[taskOrder][task].length <= 0
          list[taskOrder][task][0] = "through"

        builtList.push list[taskOrder][task]

    return builtList


  build = (list)->

    builtList = buildList(list)

    Gulp.task "default", () ->

      Sequence(
        builtList[0]
        builtList[1]
        builtList[2]
        builtList[3]
        builtList[4]
        builtList[5]
      ,
        ->
          if config.scripts and config.scripts.custom
            ExecCommand(
              config.scripts.custom
              process.cwd()
            ,
              ->
                console.log Chalk.magenta "Build Complete"
            )

          else

            message =
              level: "notify"
              message: "✔ Complete!"
              name: "Build"
              color: "green"

            Norma.events.emit "message", message

      )

    # process.nextTick( ->
    Gulp.start ["default"]
    # )



  # GENERATE-LIST -------------------------------------------------------

  if !tasks.length
    generateTaskList(fileTypes, build)

  else


    # USER-DEFINED  -----------------------------------------------------

    for task in tasks
      if !Gulp.tasks[task]
        console.log(
          Chalk.red "#{task} is not a known package"
        )
        return

    Gulp.task "default", tasks, ->

      if config.scripts and config.scripts.custom
        ExecCommand(
          config.scripts.custom
          process.cwd()
        ,
          ->
            console.log Chalk.magenta "Build Complete"
        )

    process.nextTick( ->
      Gulp.start ["default"]
    )



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

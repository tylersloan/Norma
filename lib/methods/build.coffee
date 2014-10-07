
Path = require "path"
Fs = require "fs-extra"
Sequence = require "run-sequence"
Chalk = require "chalk"
Exec = require("child_process").exec
_ = require "underscore"

MapTree = require("./directory-tools").mapTree
ReadConfig = require "./read-config"
PkgeLookup = require "./package-lookup"



module.exports = (tasks, cwd) ->

  # Load config
  config = ReadConfig process.cwd()

  # Set emtpy array for fileTypes
  fileTypes = new Array

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

    Get types of files to be compiled based on items from the config
    This can return empty things

  ###
  do (config) ->

    # Generate kind of files to compile
    for key of config

      if config[key].ext

        for ext in config[key].ext
          fileTypes.push( ext )


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


  buildList = (list) ->

    builtList = new Array

    for taskOrder of list
      for task of list[taskOrder]

        if list[taskOrder][task].length <= 0
          list[taskOrder][task][0] = "through"

        builtList.push list[taskOrder][task]

    return builtList


  ###

    runConfigCommandCommand is a utility to run post build scripts
    that can be defined per project. I think this should be abstracted
    into another file since it is used in other places on the tool.

    @todo - abstract this function

  ###
  runConfigCommand = (action, cwd, cb) ->

    file = Fs.existsSync(
      Path.join(cwd, action)
    )

    if file
      require Path.join(cwd, action)

    else
      child = Exec(action, {cwd: cwd}, (err, stdout, stderr) ->

        throw err if err

        cb()
      )
      child.stdout.setEncoding("utf8")
      child.stdout.on "data", (data) ->
        str = data.toString()
        lines = str.split(/(\r?\n)/g)

        i = 0
        while i < lines.length
          if !lines[i].match "\n"
            message = lines[i].split("] ")

            if message.length > 1
              message.splice(0, 1)

            message = message.join(" ")

            console.log message
          i++

        return

  cb = (list)->

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
            runConfigCommand(
              config.scripts.custom
              process.cwd()
            ,
              ->
                console.log Chalk.magenta "Build Complete"
            )
      )

    process.nextTick( ->
      Gulp.start ["default"]
    )





  Gulp = require "gulp"
  gulpTasks = PkgeLookup tasks, (Path.resolve __dirname, "../../")


  for task in gulpTasks
    _.extend Gulp.tasks, task



  ###

    The through task is a way to run a full sequence even
    when sequence tasks aren"t defined. It feels kinda hacky but gulp
    isn"t really meant to be used in this way. When gulp moves to full
    orchestrator support, this tool will need a serious revist.

  ###
  Gulp.task "through", (cb) ->
    cb null


  generateTaskList(fileTypes, cb)

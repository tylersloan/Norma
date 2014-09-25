
path = require 'path'
fs = require 'fs'
_ = require 'lodash'
sequence   = require "run-sequence"
chalk = require 'chalk'

mapTree = require('./dirTree').mapTree
config = require '../config/config'



module.exports = (tasks, configPath) ->

  # Load config
  config = config(configPath)

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

      The cyclomatic complexity of this statement is way too damn high.
      Need to break it apart into smaller, more efficent tasks.

    ###
    for task of gulp.tasks

      if gulp.tasks[task].ext

        for type in types

          if gulp.tasks[task].ext.indexOf(type) > -1

            if gulp.tasks[task].order

              gulp.tasks[task].type = gulp.tasks[task].type or 'async'

              saveTask(
                taskList[gulp.tasks[task].order][gulp.tasks[task].type]
                task
              )

            else
              saveTask taskList.main.async, task


    cb(taskList)

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
  folders = mapTree path.normalize(process.cwd()), ignore

  getFileTypes = (files) ->

    for child in files.children

      if child.type is 'folder'
        getFileTypes(child)
      else
        ext = path.extname(child.name)

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

  cb = (list)->

    builtList = buildList(list)

    gulp.task 'default', () ->

      sequence(
        builtList[0], builtList[1],
        builtList[2], builtList[3],
        builtList[4], builtList[5],
      ->
        console.log chalk.magenta("Build Complete")
      )

    process.nextTick( ->
      gulp.start(['default'])
    )


  gulp = require 'gulp'
  gulpFile = require '../../gulpfile'
  localGulpFile = require( path.join(process.cwd(), 'gulpfile.js'))

  ###

    The through task is a way to run a full sequence even
    when sequence tasks aren't defined. It feels kinda hacky but gulp
    isn't really meant to be used in this way. When gulp moves to full
    orchestrator support, this tool will need a serious revist.

  ###
  gulp.task "through", (cb) ->
    cb null


  generateTaskList(fileTypes, cb)

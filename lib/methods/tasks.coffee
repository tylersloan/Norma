
path = require 'path'
fs = require 'fs'
_ = require 'lodash'
gulp = require 'gulp'
gulpFile = require('../../gulpfile')
mapTree = require('./dirTree').mapTree
sequence   = require "run-sequence"
chalk = require 'chalk'





module.exports = (tasks, env) ->

  if env.configPath
    config = require(env.configPath)

  fileTypes = new Array


  generateTaskList = (types, cb) ->

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

    for task of gulp.tasks

      if gulp.tasks[task].ext

        for type in types

          if gulp.tasks[task].ext.indexOf(type) > -1
            taskList[gulp.tasks[task].order][gulp.tasks[task].type].push(task)
            # taskList.push(task)

    cb(taskList)


  getFileTypes = (files) ->

    for child in files.children

      if child.type is 'folder'
        getFileTypes(child)
      else
        ext = path.extname(child.name)
        unless fileTypes.indexOf(ext) > -1
          fileTypes.push(ext)



  getExistingFileTypes = (config) ->

    for key of config
      configItem = config[key]
      if configItem.src?
        folders = mapTree path.normalize(configItem.src)
        getFileTypes(folders)


  getExistingFileTypes(config)

  buildList = (list) ->

    builtList = new Array

    for taskOrder of list
      for task of list[taskOrder]
        if list[taskOrder][task].length > 0
          # Sync task, needs to be split into strings on build
          if task is 'sync'
            builtList.push list[taskOrder][task].join(',')
          # Async task, needs to be kept as array
          if task is 'async'
            builtList.push list[taskOrder][task]

    stringList = ''

    # overlay complex way to make a list with array values in it
    # would love a better solution here [todo]
    for list in builtList

      if typeof list isnt 'String'
        stringList += "["
        for item in list
          stringList += '"' + item + '"'
          unless _j is (list.length - 1)
            stringList += ","

        stringList += "]"
      else stringList += list

      unless _i is (builtList.length - 1)
        stringList += ","


    return stringList

  cb = (list)->

    builtList = buildList(list)

    console.log builtList
    gulp.task 'default', () ->
      sequence ["javascript","sass","templates"],["copy"], ->
        console.log chalk.green("Build: ✔ All done!")

    process.nextTick( ->
      gulp.start(['default'])
    )

  generateTaskList(fileTypes, cb)

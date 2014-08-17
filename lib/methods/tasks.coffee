
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
        unless list[taskOrder][task].length > 0
          list[taskOrder][task][0] = "through"

        builtList.push list[taskOrder][task]

    return builtList

  cb = (list)->

    builtList = buildList(list)


    gulp.task 'through', (cb) ->
      cb null


    gulp.task 'default', builtList[0], () ->
      sequence(
        builtList[1], builtList[2], builtList[3], builtList[4], builtList[5],
      ->
        console.log chalk.magenta("Build Complete")
      )

    process.nextTick( ->
      gulp.start(['default'])
    )

  generateTaskList(fileTypes, cb)

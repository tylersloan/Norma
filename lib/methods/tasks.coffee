
path = require 'path'
fs = require 'fs'
_ = require 'lodash'
gulp = require 'gulp'
gulpFile = require('../../gulpfile')
mapTree = require('./dirTree').mapTree





module.exports = (tasks, env) ->

  if env.configPath
    config = require(env.configPath)

  fileTypes = new Array


  generateTaskList = (types, cb) ->

    taskList = new Array
    for task of gulp.tasks
      if gulp.tasks[task].ext

        for type in types

          if gulp.tasks[task].ext.indexOf(type) > -1

            taskList.push(task)

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


  cb = (list)->
    gulp.task( 'default', list)

    process.nextTick( ->
      gulp.start(['default'])
    )

  generateTaskList(fileTypes, cb)

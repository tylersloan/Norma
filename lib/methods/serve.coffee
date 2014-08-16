
path = require 'path'
fs = require 'fs'
_ = require 'lodash'
gulp = require 'gulp'
gulpFile = require('../../gulpfile')
mapTree = require('./dirTree').mapTree





module.exports = (tasks, env) ->

  process.nextTick( ->
    gulp.start(['server'])
  )

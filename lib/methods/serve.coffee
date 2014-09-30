
Gulp = require "gulp"

module.exports = (tasks, env) ->

  process.nextTick( ->
    Gulp.start ["server"]
  )

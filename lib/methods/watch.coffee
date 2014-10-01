
Gulp = require "gulp"

module.exports = (tasks, cwd) ->

  process.nextTick( ->
    Gulp.start ["server"]
  )


Gulp = require "gulp"



module.exports = (tasks, cwd) ->

  Build = require("./build")(tasks, cwd)

  process.nextTick( ->
    Gulp.start ["server"]
  )

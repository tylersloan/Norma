# Gulp is the only requried dependency
Gulp = require "gulp"

module.exports = (config, tasks) ->


  ###

    This is a sample task
    A callback will be passed in order to run
    through all tasks in a sequenced method

  ###
  Gulp.task "sample", (cb) ->
    Norma.emit "message", "Your scripts go here"

    cb null

  # Set your file type(s) here
  Gulp.tasks["sample"].ext = [".sample"]

  ###

    You can specify the order this task here
    For more information about this see the Norma
    documenation site

  ###
  # Gulp.tasks["sample"].order = "post"

  # Export all of your tasks
  module.exports.tasks = Gulp.tasks

Norma = require "normajs"

module.exports = (config) ->

  ###

    This is a sample task
    A callback will be passed in order to run
    through all tasks in a sequenced method

  ###
  Norma.task "sample", (cb) ->
    Norma.emit "message", "Your scripts go here"

    cb null



  ###

    You can specify the order this task here
    For more information about this see the Norma
    documenation site

  ###
  # Norma.tasks["sample"].order = "post"

  # Export all of your tasks
  module.exports.tasks = Norma.tasks

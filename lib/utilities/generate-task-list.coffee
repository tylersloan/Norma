Gulp = require "gulp"
_ = require "underscore"

# TASKLIST --------------------------------------------------------------

module.exports = (config, types, cb) ->



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
    pre:
      sync: []
      async: []
    main:
      sync: []
      async: []
    post:
      sync: []
      async: []


  for task of Gulp.tasks

    if !Gulp.tasks[task].ext
      continue

    for type in types

      if Gulp.tasks[task].ext.indexOf(type) <= -1
        continue

      if Gulp.tasks[task].order

        Gulp.tasks[task].type = Gulp.tasks[task].type or "async"

        saveTask(
          taskList[Gulp.tasks[task].order][Gulp.tasks[task].type]
          task
        )

      else
        saveTask taskList.main.async, task


  # Mange order based on package.json
  orderedList = new Array

  if Object.keys(config.tasks).length isnt 0
    for wantedTask of config.tasks
      orderedList.push wantedTask

  for key of taskList
    if !taskList[key].sync
      continue

    if taskList[key].sync.length
      taskList[key].sync = _.intersection orderedList, taskList[key].sync



  cb taskList

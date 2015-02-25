_ = require "underscore"

# TASKLIST --------------------------------------------------------------

module.exports = (config, tasks, cb) ->

  if _.isEmpty tasks
    return []

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
      taks is defined within each task.

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


  for task of tasks

    if !config.tasks[task]
      continue

    if tasks[task].order

      tasks[task].type = tasks[task].type or "async"

      saveTask(
        taskList[tasks[task].order][tasks[task].type]
        task
      )

    else
      saveTask taskList.main.async, task


  # SYNC-ORDER -------------------------------------------------------------

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




  # REDUCE -----------------------------------------------------------------

  finalList = new Array

  for taskOrder of taskList
    for task of taskList[taskOrder]

      # empty array of tasks at level so keep going
      if !taskList[taskOrder][task].length
        continue

      # add each sync task for dynamic sequence running
      if task is "sync"
        for syncTask in taskList[taskOrder][task]
          finalList.push syncTask

      else
        finalList.push taskList[taskOrder][task]


  return finalList

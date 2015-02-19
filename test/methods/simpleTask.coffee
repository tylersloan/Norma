runCounter = 0

getCounter = ->
  runCounter++
  runCounter

simpleTask = ->

  task = (cb) ->
    if task.shouldPause
      task.cb = cb
    else
      task.counter = getCounter()
      cb()
    return

  task.shouldPause = false
  task.counter = -1
  #noinspection ReservedWordAsName

  task.continue = (err) ->
    if task.cb
      task.counter = getCounter()
      cb = task.cb
      delete task.cb
      cb err
    return

  task.reset = ->
    task.shouldPause = false
    task.counter = -1
    delete task.cb
    return

  task

simpleTask.resetRunCounter = ->
  runCounter = 0
  return

module.exports = simpleTask

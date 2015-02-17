
Orchestrator = require "orchestrator"
Inherits = require "inherits"



# SEQUENCE ---------------------------------------------------------------

verifyTaskSets = (taskSets, skipArrays) ->


  if taskSets.length is 0
    Norma.emit "error", new Error("No tasks were provided to run-sequence")

  taskSets.forEach (t) ->

    isTask = typeof t == "string"
    isArray = !skipArrays and Array.isArray(t)


    if !isTask and !isArray
      Norma.emit(
        "error"
        new Error "Task " + t + " is not a valid task string."
      )

    if isArray
      if t.length is 0
        Norma.emit(
          "error"
          new Error "An empty array was provided as a task set"
        )
      verifyTaskSets t, true
    return

  return

runSequence = (norma) ->

  taskSets = Array::slice.call(arguments, 1)

  if typeof taskSets[taskSets.length - 1] is "function"
    callBack = taskSets.pop()
  else
    callBack = false

  currentTaskSet = undefined

  finish = (err) ->
    Norma.removeListener "task_stop", onTaskEnd
    Norma.removeListener "task_err", onError

    if callBack
      callBack err
    else if err
      Norma.emit "message", "Error running task sequence: #{err}"
    return

  onError = (err) ->
    finish err
    return

  onTaskEnd = (event) ->
    idx = currentTaskSet.indexOf(event.task)
    if idx > -1
      currentTaskSet.splice idx, 1
    if currentTaskSet.length == 0
      runNextSet()
    return

  runNextSet = ->
    if taskSets.length

      command = taskSets.shift()

      if !Array.isArray(command)
        command = [ command ]

      currentTaskSet = command

      Norma.start.apply norma, command
    else
      finish()
    return

  verifyTaskSets taskSets

  Norma.on "task_stop", onTaskEnd
  Norma.on "task_err", onError
  runNextSet()
  return


module.exports = runSequence.bind(null, Norma)

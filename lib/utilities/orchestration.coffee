
Orchestrator = require "orchestrator"
Inherits = require "inherits"

module.exports = ->

  _norma = ->
    Orchestrator.call this
    return

  Inherits _norma, Orchestrator

  _norma::task = _norma::add;

  inst = new _norma

  Norma.tasks = inst.tasks
  Norma.isRunning = inst.isRunning
  Norma.seq = inst.seq
  Norma.add = inst.add
  Norma.doneCallback = inst.doneCallback


  # SEQUENCE ---------------------------------------------------------------

  verifyTaskSets = (taskSets, skipArrays) ->

    if taskSets.length == 0
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
        if t.length == 0
          Norma.emit(
            "error"
            new Error "An empty array was provided as a task set"
          )
        verifyTaskSets t, true
      return

    return

  runSequence = ->

    taskSets = Array::slice.call(arguments, 1)

    if typeof taskSets[taskSets.length - 1] is "function"
      callBack = taskSets.pop()
    else
      callBack = false

    currentTaskSet = undefined

    finish = (err) ->
      inst.removeListener "task_stop", onTaskEnd
      inst.removeListener "task_err", onError

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
        inst.start.apply inst, command
      else
        finish()
      return

    verifyTaskSets taskSets
    inst.on "task_stop", onTaskEnd
    inst.on "task_err", onError
    runNextSet()
    return


  Norma.sequence = runSequence.bind(null)

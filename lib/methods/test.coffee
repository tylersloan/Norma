Path = require "path"
Fs = require "fs"
_ = require "underscore"
Q = require "kew"


Norma = require "./../norma"
Run = require "./../utilities/run-script"



module.exports = (tasks, cwd) ->

  cwd or= process.cwd()

  tested = Q.defer()

  # Force verbose and debug
  Norma.verbose = true
  Norma.debug = true

  msg =
    color: "green"
    message: "✔ Testing your project!"

  Norma.emit "message", msg

  config = Norma.config cwd

  if not config.test

    packageJSON = Path.join(cwd, "package.json")
    packageJSON = Fs.readFileSync packageJSON, encoding: "utf8"
    packageJSON = JSON.parse(packageJSON)

    if not packageJSON.scripts.test
      tested.fail("no tests found")
      return tested

    test = packageJSON.scripts.test

  else
    test = config.test


  # METHODS --------------------------------------------------------------
  chainCallbacks = (indexer, array, callback) ->

    # have not reached end of array
    if array.length - 1 > indexer
      Run array[indexer], cwd, (err, result) ->

        if err
          tested.reject err
          return

        indexer++
        chainCallbacks indexer, array, callback

      return

    # last element
    if array.length - 1 is indexer
      Run array[indexer], cwd, (err, result) ->
        callback err, result

      return

    return


  # AFTER ACTIONS ---------------------------------------------------------

  runAfter = ->

    afterCallback = (err, result) ->
      if err
        tested.reject err
        return

      # force prompt to close if open for graceful exit
      Norma.prompt.pause()
      tested.resolve result
      return


    if test.after

      # are we an array
      if _.isArray test.after
        # set count to 0 for stepping through array
        afterCount = 0
        chainCallbacks afterCount, test.after, afterCallback

        return

      # invalid data type for after test
      if typeof test.after isnt "string"
        Norma.emit "error", "after actions must be an array or string"
        return

      # Just a string after action
      Run test.after, cwd, afterCallback

      return

    afterCallback null, "ok"


  # MAIN ACTIONS ----------------------------------------------------------
  runActions = ->

    actionCallback = (err, result) ->

      if err
        tested.fail err
        return

      runAfter null

    # single string as test
    if typeof test is "string"
      Run test, cwd, actionCallback


    # a set of main tasks
    if test.main

      # test is a single string
      if typeof test.main is "string"
        Run test.main, cwd, actionCallback

        return

      # array of tasks
      if _.isArray test.main

        # set count to 0 for stepping through array
        mainCount = 0
        chainCallbacks mainCount, test.main, actionCallback

        return

      return


    # create build queue
    taskArray = []
    for task of test

      if task is "before" or task is "after"
        continue

      taskArray.push task



    Norma.build(taskArray, cwd)
      .then( (result) ->
        actionCallback null, result
      )
      .fail( (error) ->
        actionCallback error
      )


    return


  do ->
    beforeCallback = (err, result) ->
      if err
        tested.reject err
        return

      runActions null

    if test.before

      # are we an array
      if _.isArray test.before
        # set count to 0 for stepping through array
        count = 0
        chainCallbacks count, test.before, beforeCallback

        return

      # invalid data type for before action
      if typeof test.before isnt "string"

        Norma.emit "error", "before actions must be an array or string"
        return

      # just a string before action
      Run test.before, cwd, beforeCallback

      return

    beforeCallback null




  # 1. packages
  # 2. files? (is this needed? or can you just node ./index.js)
  # 3. shell commands





# API ----------------------------------------------------------------------

module.exports.api = [
  {
    command: ""
    description: "continuously test your package"
  }
  {
    command: "build"
    description: "test build of package"
  }
]

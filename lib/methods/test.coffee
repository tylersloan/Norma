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
      Run array[count], cwd, (err, result) ->
        callback err, result

      return

    return


  # START TEST -----------------------------------------------------------
  if typeof test is "string"

    Run test, cwd, (err, result) ->

      if err
        tested.fail err
        return

      tested.resolve result

    return

  if test.before

    beforeCallback = (err, result) ->
      if err
        tested.reject err
        return

      Norma.log "start running tests now that before task is done"


    # are we an array
    if _.isArray test.before
      # set count to 0 for stepping through array
      count = 0
      chainCallbacks count, test.before, beforeCallback

      return


    if typeof test.before isnt "string"

      Norma.emit "error", "before actions must be an array or string"
      return

    Run test.before, cwd, beforeCallback




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

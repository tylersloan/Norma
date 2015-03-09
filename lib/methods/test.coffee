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


  if typeof test is "string"

    Run test, cwd, (err, result) ->

      if err
        tested.fail err
        return

      tested.resolve result

    return

  if test.before

    # are we an array
    if _.isArray test.before

      # set count to 0 for stepping through array
      count = 0

      chainCallbacks = (count, array) ->

        # have not reached end of array
        if array.length - 1 > count
          Run array[count], cwd, (err, result) ->

            if err
              tested.reject err
              return

            count++
            chainCallbacks count, array

          return

        # last element
        if array.length - 1 is count
          Run array[count], cwd, (err, result) ->

            if err
              tested.reject err
              return

            Norma.log "start running tests now that before task is done"

          return


      chainCallbacks 0, test.before


      #   _obj = {}
      #   _obj[testAction] = Q.defer()
      #
      #   Run testAction, cwd, _obj[testAction].makeNodeResolver()
      #   beforePromises.push _obj[testAction]
      #
      # Q.all(beforePromises)
      #   .then( (result) ->
      #     Norma.log "start running tests now that before task is done"
      #   )
      #   .fail( (error) ->
      #     tested.fail error
      #     return
      #   )
      #

      return

    if typeof test.before isnt "string"

      Norma.emit "error", "before actions must be an array or string"
      return

    # make a single promise for before script
    beforeTest = Q.defer()
    Run test.before, cwd, beforeTest.makeNodeResolver()

    beforeTest
      .then( (result) ->
        Norma.log "start running tests now that before task is done"
      )
      .fail( (error) ->
        tested.fail error
        return
      )





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

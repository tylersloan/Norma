Path = require "path"
Fs = require "fs"
_ = require "underscore"
Q = require "kew"
Spawn = require("child_process").spawn

Norma = require "./../norma"



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


  # TEST-TYPES --------------------------------------------------------------

  # not an object detailing test
  if typeof test is "string"
    # split into args
    testArray = test.split(" ")

    # check norma packages
    if Norma.tasks[testArray[0]]

      Norma.log "build out package based test here"
      tested.resolve("ok")

      return tested


    # check to see if test is a path
    if Fs.existsSync Path.resolve(cwd, testArray[0])
      action = "node"
      commands = [Path.resolve(cwd, testArray[0])]

    # spawn process executing test action
    else
      action = testArray[0]
      # copy array
      commands = testArray.slice()
      # remove first item
      commands.shift()


    _test = Spawn(
      action
      commands
      {
        cwd: cwd
        stdio: [
          0
          1
          2
        ]
      }
    )

    _test.on "close", (code, signal) ->
      if code is not 0
        tested.fail signal
        Norma.emit "error", "testing failed"
        return

      tested.resolve("ok")
      return

    return tested





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

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



  Run test, cwd, (err, result) ->

    if err
      tested.fail err
      return

    tested.resolve result





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

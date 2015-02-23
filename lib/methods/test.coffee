Path = require "path"
Chalk = require "chalk"
_ = require "underscore"

Norma = require "./../norma"
ReadConfig = require "./../utilities/read-config"


module.exports = (tasks, cwd) ->

  normaConfig = ReadConfig process.cwd()

  # Force verbose and debug
  Norma.verbose = true
  Norma.debug = true

  if normaConfig.type is "package"


    msg =
      color: "green"
      message: "✔ Testing your package!"

    Norma.emit "message", msg


    if tasks[0] is "build"
      Norma.build tasks, cwd

    else
      Norma.watch tasks, cwd



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

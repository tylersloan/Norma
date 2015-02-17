Path = require "path"
Chalk = require "chalk"
_ = require "underscore"

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


    if tasks[0] is "watch"

      Norma.watch tasks, cwd

    else
      Norma.build tasks, cwd



# API ----------------------------------------------------------------------

module.exports.api = [
  {
    command: ""
    description: "test your project/package"
  }
  {
    command: "--watch"
    description: "continuously test project/package"
  }
]

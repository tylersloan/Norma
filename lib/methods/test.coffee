Path = require "path"
Chalk = require "chalk"
_ = require "underscore"


Build = require "./../methods/build"
Watch = require "./../methods/watch"
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


    if Norma.watch

      Watch tasks, cwd

    else
      Build tasks, cwd



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

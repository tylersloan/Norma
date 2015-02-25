Path = require "path"
Chalk = require "chalk"
_ = require "underscore"
Q = require "kew"

Norma = require "./../norma"
ReadConfig = require "./../utilities/read-config"


module.exports = (tasks, cwd) ->

  tested = Q.defer()

  # Force verbose and debug
  Norma.verbose = true
  Norma.debug = true

  msg =
    color: "green"
    message: "✔ Testing your project!"

  Norma.emit "message", msg


  if tasks[0] is "build"

    tasks.shift()
    
    Norma.build(tasks, cwd)
      .then( ->
        tested.resolve "ok"
      )
      .fail( (err) ->
        tested.reject err
      )

    return tested

  else
    Norma.watch tasks, cwd

    return tested



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

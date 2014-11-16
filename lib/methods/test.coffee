Path = require "path"
Multimatch = require "multimatch"
Findup = require "findup-sync"
Chalk = require "chalk"
Gulp = require "gulp"
Flags = require("minimist")( process.argv.slice(2) )
_ = require "underscore"

Build = require "./../methods/build"
Watch = require "./../methods/watch"
Start = require "./../methods/start"

ReadConfig = require "./../utilities/read-config"


module.exports = (tasks, cwd) ->

  normaConfig = ReadConfig process.cwd()

  if normaConfig.type is "process"

    console.log(
      Chalk.green "✔ Testing your process!"
    )

    Start tasks, cwd

  else if normaConfig.type is "package"

    console.log(
      Chalk.green "✔ Testing your package!"
    )

    if Flags.watch

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

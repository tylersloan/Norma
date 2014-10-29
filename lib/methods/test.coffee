Path = require "path"
Multimatch = require "multimatch"
Findup = require "findup-sync"
Chalk = require "chalk"
Gulp = require "gulp"
Flags = require("minimist")( process.argv.slice(2) )
_ = require "underscore"

Build = require "./../methods/build"
ReadConfig = require "./../utilities/read-config"


module.exports = (tasks, cwd) ->

  normaConfig = ReadConfig process.cwd()

  if normaConfig.type is "package"

    console.log(
      Chalk.green "✔ Testing your package!"
    )

    Build tasks, cwd


# API ----------------------------------------------------------------------

module.exports.api = [
  {
    command: ""
    description: "test your project"
  }
  {
    command: "--package"
    description: "test your packagge"
  }
]
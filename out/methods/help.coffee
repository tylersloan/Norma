
Path = require "path"

Norma = require "./../norma"
Logger = require "./../logging/logger"

module.exports = ->

  cliPackage = require Path.join __dirname, "../../package.json"

  Logger.logInfo(cliPackage)

  Norma.stop()


module.exports.api = [
  {
    command: ""
    description: "print out logs"
  }

]

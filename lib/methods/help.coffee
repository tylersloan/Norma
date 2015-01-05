
Path = require "path"

Logger = require "./../logging/logger"

module.exports = ->

  cliPackage = require Path.join __dirname, "../../package.json"

  Logger.logInfo(cliPackage)

  process.exit 0


module.exports.api = [
  {
    command: ""
    description: "print out logs"
  }

]

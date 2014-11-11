
Path = require "path"
ReadConfig = require "./read-config"


module.exports = (cwd, tasks) ->

  config = ReadConfig cwd

  console.log config, tasks

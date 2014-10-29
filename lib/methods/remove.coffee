Fs = require "fs-extra"
Path = require "path"
ReadConfig = require "./../utilities/read-config"
Exec = require('child_process').exec
Flags = require('minimist')( process.argv.slice(2) )

RemoveTree = require('./../utilities/directory-tools').removeTree


module.exports = (tasks, cwd) ->

  if Flags.scaffold
    tasks[1] = Flags.scaffold

    scaffoldLocation = Path.resolve __dirname, "../../scaffolds/", tasks[1]

    RemoveTree scaffoldLocation


# API ----------------------------------------------------------------------

module.exports.api = [
  # {
  #   command: ""
  #   description: "list all available packages"
  # }
  {
    command: "<name> --scaffold"
    description: "remove scaffold from #{Tool}"
  }
]

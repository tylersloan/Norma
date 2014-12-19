Path = require "path"
Fs = require "fs-extra"
Multimatch = require "multimatch"
Findup = require "findup-sync"

ExecCommand = require "./../utilities/execute-command"

module.exports = (tasks, cwd) ->

  # User tried to run `norma add` without argument
  if !tasks.length

    msg =
      level: "notify"
      name: "Norma"
      message: "Updating Norma..."

    Norma.events.emit "message", msg

    process.chdir Path.resolve __dirname, "../../"

    ExecCommand(
      "npm update -g normajs"
      process.cwd()
    )

    return

  if tasks.length is 1 and tasks[0] is "all"

    packageList = new Array

    # npm package testing
    pattern = [
      "#{Tool}-*"
      "#{Tool}.*"
    ]


    config = Findup "package.json", cwd: cwd

    node_modules = Findup "node_modules", cwd: cwd

    scope = [
      "dependencies"
      "devDependencies"
      "peerDependencies"
    ]

    replaceString = /^norma(-|\.)/


    if config and node_modules

      # Using the require method keeps the same in memory, instead we use
      # a synchronous fileread of the JSON. This should probably be in a try
      # with a Norma error emitted on fail

      # TODO - wrap in try catch with error
      config = Fs.readFileSync config, encoding: "utf8"


      try
        config = JSON.parse(config)
      catch err
        err.level = "crash"

        Norma.events.emit "error", err


      names = scope.reduce(
        (result, prop) ->

          result.concat Object.keys(config[prop] or {})
        []
      )

      Multimatch(names, pattern).forEach (name) ->

        packageList.push name

        return

      packageList = packageList.join " "

      msg =
        level: "notify"
        name: "Norma"
        message: "Updating all local packages..."

      Norma.events.emit "message", msg

      ExecCommand(
        "npm update #{packageList}"
        cwd
      )


  else

    taskList = (
      "#{Tool}-#{task}" for task in tasks
    )

    tasks = taskList.join(" ")

    msg =
      level: "notify"
      name: "Norma"
      message: "Updating #{tasks}..."

    Norma.events.emit "message", msg

    ExecCommand(
      "npm update #{tasks}"
      cwd
    )



# API ----------------------------------------------------------------------

module.exports.api = [
  {
    command: ""
    description: "a blank update will update Norma globally"
  }
  {
    command: "all"
    description: "update all packages for Norma locally"
  }
  {
    command: "all --global"
    description: "update all packages for Norma globally"
  }
  {
    command: "<package>"
    description: "update a package for Norma locally"
  }
  {
    command: "<package> --global"
    description: "update a package for Norma globally"
  }
  {
    command: "<package> <package>"
    description: "update multiple packages for Norma locally"
  }
  {
    command: "<package> <package> --global"
    description: "update multiple packages for Norma globally"
  }
]

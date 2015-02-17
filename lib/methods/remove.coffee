Fs = require "fs"
Path = require "path"
Chalk = require "chalk"

ReadConfig = require "./../utilities/read-config"
ExecCommand = require "./../utilities/execute-command"
RemoveTree = require('./../utilities/directory-tools').removeTree


module.exports = (tasks, cwd) ->

  # LOGS -------------------------------------------------------------------

  # User tried to run `norma add` without argument
  if !tasks.length

    err =
      level: "crash"
      name: "Missing Info"
      message: "Please specify a task or --scaffold <name>"

    Norma.emit "error", err



  # SCAFFOLD ---------------------------------------------------------------

  if Norma.scaffold
    tasks[1] = Norma.scaffold

    scaffoldLocation = Path.resolve Norma.userHome, "scaffolds/", tasks[1]

    RemoveTree scaffoldLocation



  # PACKAGES ---------------------------------------------------------------

  config = Path.resolve process.cwd(), "package.json"

  if !config

    message = "No package.json found, please run `npm init` in the root"

    err =
      level: "crash"
      name: "Missing Info"
      message: message

    Norma.emit "error", err


  ###
    Here we allow users to specify a number of pacakges to be added
    both localy or globally in a single command.
    The command can be norma add <package> <package> <package>
    and it will add all of them with a norma- prepended prior
    to the npm install
  ###

  # Quick add method for norma
  taskList = (
    "norma-#{task}" for task in tasks
  )

  tasks = taskList.join(" ")


  ###
    @note
      As of Norma alpha, the npm package does not support dev installing.
      Once it does, it will replace the child proccess method done below
  ###
  if Norma.dev
    action = "npm uninstall --save-dev #{taskList}"
  else
    action = "npm uninstall --save #{taskList}"


  if Norma.global or Norma.g

    Norma.emit "message", "Removing packages to your global norma..."
  

    # Do work on users global norma
    process.chdir Path.resolve Norma.userHome, "packages"

    ExecCommand(
      action
      process.cwd()
    ,
      ->
        # Change back to project cwd for further tasks
        process.chdir cwd

        Norma.emit "message", "Packages removed!"

        if typeof cb is 'function'
          cb()

    )

  else

    Norma.emit "message", "Removing packages to your local norma..."

    ExecCommand(
      action
      process.cwd()
    ,
      ->

        Norma.emit "message", "Packages removed!"

        if typeof cb is 'function'
          cb()

    )


# API ----------------------------------------------------------------------

module.exports.api = [
  {
    command: "<name> --scaffold"
    description: "remove scaffold from norma"
  }
  {
    command: "<package-name>"
    description: "remove local package"
  }
  {
    command: "<package-name> --dev"
    description: "remove local package as a dev dependency"
  }
  {
    command: "<package-name> --global"
    description: "remove global package"
  }
]

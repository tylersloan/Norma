Fs = require "fs"
Path = require "path"

Q = require "kew"
_ = require "underscore"



module.exports = (tasks, cwd, scaffold) ->

  Norma = require "./../norma"

  ExecCommand = require "./../utilities/execute-command"
  RemoveTree = require('./../utilities/directory-tools').removeTree


  removeStatus = Q.defer()

  # Allow override via --scaffold
  if Norma.scaffold then scaffold = true

  if !cwd then cwd = process.cwd()

  # LOGS -------------------------------------------------------------------

  # User tried to run `norma add` without argument
  if !tasks or !tasks.length

    err =
      level: "crash"
      name: "Missing Info"
      message: "Please specify a task or --scaffold <name>"

    Norma.emit "error", err
    removeStatus.reject err
    return removeStatus



  # SCAFFOLD ---------------------------------------------------------------

  if scaffold

    scaffoldLocation = Path.resolve Norma._.userHome, "scaffolds/", tasks[0]

    if !Fs.existsSync scaffoldLocation
      err =
        level: "crash"
        name: "Missing Scaffold"
        message: "#{tasks[0]} was not found to remove"

      Norma.emit "error", err
      removeStatus.reject err
      return removeStatus

    RemoveTree scaffoldLocation
    removeStatus.resolve "ok"
    return removeStatus



  # PACKAGES ---------------------------------------------------------------

  config = Path.resolve cwd, "package.json"

  if !config

    message = "No package.json found, please run `npm init` in the root"

    err =
      level: "crash"
      name: "Missing Info"
      message: message

    Norma.emit "error", err

    removeStatus.reject err
    return removeStatus


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

    @note this needs to be expanded to support programmtic removals

  ###
  if Norma.dev
    action = "npm uninstall --save-dev #{taskList}; npm prune"
  else
    action = "npm uninstall --save #{taskList}; npm prune"


  if Norma.global

    Norma.emit "message", "Removing packages to your global norma..."


    # Do work on users global norma
    process.chdir Path.resolve Norma._.userHome

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

        removeStatus.resolve "ok"
    )

  else

    Norma.emit "message", "Removing packages to your local norma..."

    ExecCommand(
      action
      cwd
    ,
      ->

        Norma.emit "message", "Packages removed!"

        if typeof cb is 'function'
          cb()

        removeStatus.resolve "ok"

    )

  return removeStatus


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

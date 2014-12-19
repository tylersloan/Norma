Fs = require "fs-extra"
Path = require "path"
Flags = require('minimist')( process.argv.slice(2) )
Findup = require "findup-sync"
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

    Norma.events.emit "error", err



  # SCAFFOLD ---------------------------------------------------------------

  if Flags.scaffold
    tasks[1] = Flags.scaffold

    scaffoldLocation = Path.resolve __dirname, "../../scaffolds/", tasks[1]

    RemoveTree scaffoldLocation



  # PACKAGES ---------------------------------------------------------------

  config = Findup "package.json", cwd: process.cwd()

  if !config

    message = "No package.json found, please run `npm init` in the root"

    err =
      level: "crash"
      name: "Missing Info"
      message: message

    Norma.events.emit "error", err


  ###
    Here we allow users to specify a number of pacakges to be added
    both localy or globally in a single command.
    The command can be norma add <package> <package> <package>
    and it will add all of them with a norma- prepended prior
    to the npm install
  ###

  # Quick add method for norma
  taskList = (
    "#{Tool}-#{task}" for task in tasks
  )

  tasks = taskList.join(" ")


  ###
    @note
      As of Norma alpha, the npm package does not support dev installing.
      Once it does, it will replace the child proccess method done below
  ###
  if Flags.dev
    action = "npm uninstall --save-dev #{taskList}"
  else
    action = "npm uninstall --save #{taskList}"


  if Flags.global or Flags.g

    console.log(
      Chalk.green "Removing packages to your global #{Tool}..."
    )

    # Do work on users global norma
    process.chdir Path.resolve __dirname, "../../packages"

    ExecCommand(
      action
      process.cwd()
    ,
      ->
        # Change back to project cwd for further tasks
        process.chdir cwd

        console.log(
          Chalk.magenta "Packages removed!"
        )

        if typeof cb is 'function'
          cb()

    )

  else

    console.log(
      Chalk.green "Removing packages to your local #{Tool}..."
    )

    ExecCommand(
      action
      process.cwd()
    ,
      ->

        console.log(
          Chalk.magenta "Packages removed!"
        )

        if typeof cb is 'function'
          cb()

    )


# API ----------------------------------------------------------------------

module.exports.api = [
  {
    command: "<name> --scaffold"
    description: "remove scaffold from #{Tool}"
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

Path = require "path"
Exec = require("child_process").exec
Chalk = require "chalk"
Flags = require("minimist")( process.argv.slice(2) )
Ghdownload = require "github-download"
Findup = require "findup-sync"

ExecCommand = require "./../utilities/execute-command"



module.exports = (tasks, cwd, cb) ->



  # LOGS -------------------------------------------------------------------

  # User tried to run `norma add` without argument
  if !tasks.length

    err =
      level: "crash"
      name: "Missing Info"
      message: "Please specify a task or --scaffold <repo>"

    Norma.events.emit "error", err


  # SCAFFOLD ---------------------------------------------------------------

  if Flags.scaffold

    # Clean out args to find git repo
    tasks[0] = Flags.scaffold
    finalLoc = tasks[0].split "norma-"
    finalLoc = finalLoc[1]

    # Get final resting place of global scaffolds
    scaffoldLocation = Path.resolve __dirname, "../../scaffolds/", finalLoc

    # Download from github
    Ghdownload(
      tasks[0]
      scaffoldLocation + "/"
    ).on "end", ->
      Exec "tree", (err, stdout, sderr) ->
        console.log "Scaffold ready!"
        return

    return


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
    action = "npm i --save-dev #{taskList}"
  else
    action = "npm i --save #{taskList}"


  if Flags.global or Flags.g

    console.log(
      Chalk.green "Installing packages to your global #{Tool}..."
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
          Chalk.magenta "Packages installed!"
        )

        if typeof cb is 'function'
          cb()

    )

  else

    console.log(
      Chalk.green "Installing packages to your local #{Tool}..."
    )

    ExecCommand(
      action
      process.cwd()
    ,
      ->

        console.log(
          Chalk.magenta "Packages installed!"
        )

        if typeof cb is 'function'
          cb()

    )



# API ----------------------------------------------------------------------

module.exports.api = [
  {
    command: "<git-repo> --scaffold"
    description: "install global scaffold"
  }
  {
    command: "<package-name>"
    description: "install local package"
  }
  {
    command: "<package-name> --dev"
    description: "install local package as a dev dependency"
  }
  {
    command: "<package-name> --global"
    description: "install global package"
  }
]

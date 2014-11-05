Path = require "path"
Exec = require("child_process").exec
Chalk = require "chalk"
Flags = require("minimist")( process.argv.slice(2) )
Ghdownload = require "github-download"
Findup = require "findup-sync"

ExecCommand = require "./../utilities/execute-command"


module.exports = (tasks, cwd) ->


  # LOGS -------------------------------------------------------------------

  # User tried to run `norma add` without argument
  if tasks.length is 1

    console.log Chalk.red "Please specify a task or --scaffold <repo>"

    process.exit 0


  # SCAFFOLD ---------------------------------------------------------------

  if Flags.scaffold

    # Clean out args to find git repo
    tasks[1] = Flags.scaffold
    finalLoc = tasks[1].split "norma-"
    finalLoc = finalLoc[1]

    # Get final resting place of global scaffolds
    scaffoldLocation = Path.resolve __dirname, "../../scaffolds/", finalLoc

    # Download from github
    Ghdownload(
      tasks[1]
      scaffoldLocation + "/"
    ).on "end", ->
      Exec "tree", (err, stdout, sderr) ->
        console.log "Scaffold ready!"
        return

    return


  # PACKAGES ---------------------------------------------------------------

  config = Findup "package.json", cwd: process.cwd()

  if !config
    console.log(
      Chalk.red("No package.json found, ") +
      Chalk.red("please run `npm init` in the root")
    )

    process.exit 0

  ###

    Here we allow users to specify a number of pacakges to be added
    both localy or globally in a single command.

    The command can be norma add <package> <package> <package>
    and it will add all of them with a norma- prepended prior
    to the npm install

  ###
  taskList = tasks
  taskList.shift()

  taskList = (
    "#{Tool}-#{task}" for task in taskList
  )

  taskList = taskList.join(" ")

  if Flags.dev
    action = "npm i --save-dev #{taskList}"
  else
    action = "npm i --save #{taskList}"


  if Flags.global

    console.log(
      Chalk.green "Installing packages to your global #{Tool}..."
    )

    # Do work on users global norma
    process.chdir Path.resolve __dirname, "../../"

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
        process.exit 0
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

        process.exit 0
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

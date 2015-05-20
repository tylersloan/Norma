Path = require "path"
Exec = require("child_process").exec
Ghdownload = require "github-download"
Fs = require "fs"
Q = require "kew"
_ = require "underscore"

Norma = require "./../norma"
ExecCommand = require "./../utilities/execute-command"
MkDir = require("./../utilities/directory-tools").mkdir
RemoveSync = require("./../utilities/directory-tools").removeSync

module.exports = (tasks, cwd, scaffold) ->

  installStatus = Q.defer()

  # Norma.install({name: "javascript"})
  if tasks and _.isObject(tasks) and !_.isArray(tasks)
    tasks = [tasks]

  # Norma.install([], true)
  if typeof cwd is "boolean"
    scaffold = cwd
    cwd = null

  # Allow override via --scaffold
  if Norma.scaffold then scaffold = true


  # verify cwd
  if !cwd then cwd = process.cwd()


  # LOGS -------------------------------------------------------------------

  # User tried to run `norma add` without argument
  if !tasks or !tasks.length

    err =
      level: "crash"
      name: "Missing Info"
      message: "Please specify a task or --scaffold <repo>"

    Norma.emit "error", err


    installStatus.reject err
    return installStatus



  # SCAFFOLD ---------------------------------------------------------------

  if scaffold

    # Clean out args to find git repo
    finalLoc = tasks[0].split "norma-"


    if finalLoc.length < 2
      err =
        level: "crash"
        name: "Incorrect name of scaffold"
        message: "Please specify a scaffold name that resembles
          Organization/norma-xxxx or a full git repo containing norma-xxxx"

      Norma.emit "error", err


      installStatus.reject err
      return installStatus


    finalLoc = finalLoc[1].split(".git")[0]

    MkDir Path.resolve Norma._.userHome, "scaffolds"

    # Get final resting place of global scaffolds
    scaffoldLocation = Path.resolve Norma._.userHome, "scaffolds", finalLoc

    # remove existing scaffold
    if Fs.existsSync scaffoldLocation
      RemoveSync scaffoldLocation


    # Download from github
    Ghdownload(
      tasks[0]
      scaffoldLocation + "/"
    ).on "end", ->

      Norma.emit "message", "Scaffold ready!"

      if err
        installStatus.reject err

      installStatus.resolve "ok"

    return installStatus



  # PACKAGES ----------------------------------------------------------------

  ###

    Here we allow users to specify a number of pacakges to be added
    both localy or globally in a single command.

    The command can be norma add <package> <package> <package>
    and it will add all of them with a norma- prepended prior
    to the npm install

    @note

      As of Norma alpha, the npm package does not support dev installing.
      Once it does, it will replace the child proccess method done below

  ###


  globalAdd = (list, dev, cb) ->

    if Norma.dev or dev
      action = "npm i --save-dev #{list}"
      Norma.emit "message", "Installing dev-packages to your global norma..."
    else
      action = "npm i --save #{list}"
      Norma.emit "message", "Installing packages to your global norma..."


    MkDir Path.resolve Norma._.userHome, "packages"

    pgkeJSON = Path.resolve(Norma._.userHome, "packages/package.json")

    if !Fs.existsSync( pgkeJSON )

      defaultPackageData =
        name: "global-packages"
        version: "1.0.0"
        description: "global packages for Norma build tool"
        main: "index.js"
        scripts:
          test: "echo \"Error: no test specified\" && exit 1"
        author: ""
        license: "MIT"
        repository:
          type: "git"
          url: "https://github.com/NewSpring/norma.git"
        README: "  "

      Fs.writeFile pgkeJSON, JSON.stringify(defaultPackageData, null, 2)


    # Do work on users global norma
    cwd = Path.resolve Norma._.userHome, "packages"

    ExecCommand(
      action
      cwd
    ,
      ->

        if typeof cb is "function"
          cb null

    )


  localAdd = (list, dev, cb) ->

    if Norma.dev or dev
      action = "npm i --save-dev #{list}"
      Norma.emit "message", "Installing dev-packages to your local norma..."

    else
      action = "npm i --save #{list}"

      Norma.emit "message", "Installing packages to your local norma..."

    ExecCommand(
      action
      cwd
    ,
      ->

        cb null

    )

  # PROMISES ---------------------------------------------------------------

  promiseFunctions = []
  obj = {}
  count = 1

  install = (arr, global, dev) ->

    if !arr.length
      return

    count++
    obj[count] = Q.defer()


    if Norma.global or global
      globalAdd arr, dev, obj[count].makeNodeResolver()
    else
      localAdd arr, dev, obj[count].makeNodeResolver()

    promiseFunctions.push obj[count]



  # PACKAGES ---------------------------------------------------------------

  config = Path.resolve process.cwd(), "package.json"

  if !Fs.existsSync config

    message = "No package.json found, please run `npm init` in the root"

    err =
      level: "crash"
      name: "Missing Info"
      message: message

    Norma.emit "error", err


  # COMMAND LINE ----------------------------------------------------------

  cmdLineInstalls = []

  for task, index in tasks by -1
    if typeof task isnt "string"
      continue
    # super rough test to check git url
    if task.match /\//g
      cmdLineInstalls.push task
    else
      cmdLineInstalls.push "norma-#{task}"

    tasks.splice(index, 1)

  cmdLineInstalls = cmdLineInstalls.join(" ")

  install cmdLineInstalls


  # CONFIG ----------------------------------------------------------------

  configInstall = (dev) ->

    if !tasks.length
      return

    localInstalls = []
    globalInstalls = []

    for task, index in tasks by -1
      if task.dev and not dev
        continue

      if task.global
        if task.endpoint
          globalInstalls.push task.endpoint
        else
          globalInstalls.push "norma-#{task.name}"

      else if task.endpoint
        localInstalls.push task.endpoint

      else
        localInstalls.push "norma-#{task.name}"

      # remove for shorter loops
      tasks.splice(index, 1)

    localInstalls = _.uniq(localInstalls).join(" ")

    globalInstalls = _.uniq(globalInstalls).join(" ")

    # no global Norma in package.json
    install localInstalls, false, dev

    # Global Norma in package.json
    install globalInstalls, true, dev


  # install main dependencies
  configInstall false

  # install dev dependencies
  configInstall true



  # INSTALL ----------------------------------------------------------------
  # once all installs are done continue
  Q.all(promiseFunctions)
    .then( ->

      Norma.emit "message", "Packages installed!"

      installStatus.resolve "ok"
    )

  return installStatus



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

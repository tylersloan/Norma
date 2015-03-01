###

  This file executes when a user says "norma create <name> --package".  A new
  directory has been created for the new norma package and the process has
  already moved to that directory.  This script will put a template file in the
  directory and initialize the directory as a npm and norma package.

###


Path = require "path"
Fs = require "fs"
Chalk = require "chalk"
_ = require "underscore"

Norma = require "./../norma"
CopySync = require("./directory-tools").copySync
ExecCommand = require "./execute-command"


module.exports = (tasks, cwd) ->

  if !cwd then cwd = process.cwd()

  # cwd = absolute path of directory where package is to be created
  # tasks = [ <appName> ] - flags are not included in the array

  Norma.emit "message", "Creating your package..."

  # PACKAGE-TEMPLATE ----------------------------------------------------

  # __dirname is the directory that the currently executing script resides in
  CopySync(
    Path.resolve __dirname , "./base-package.coffee"
    Path.join cwd, "package.coffee"
  )

  # NORMA.JSON ----------------------------------------------------------

  packageName = tasks[0]

  if packageName.indexOf "norma-" isnt 0
    packageName = "norma-#{packageName}"

  config =
    name: packageName
    type: "package"
    main: "package.coffee"
    tasks: {}

  # Save config
  Fs.writeFileSync(
    Path.join(cwd, "norma.json")
    JSON.stringify(config, null, 2)
  )

  # PACKAGE.JSON --------------------------------------------------------

  pkgeConfig =
    name: packageName
    version: "0.0.1"
    description: "#{packageName.replace('norma-', '')} package for the Norma build tool"
    main: "package.coffee"
    keywords: [
      "norma"
    ]

  # Save package.json
  Fs.writeFileSync(
    Path.join(cwd, "package.json")
    JSON.stringify(pkgeConfig, null, 2)
  )

  ExecCommand(
    "npm i --save normajs"
    cwd
  ,
    ->
      Norma.emit "message", "Package Ready!"
  )


  return

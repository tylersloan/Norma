###

  This file executes when a user says "norma create <name> --package".  A new
  directory has been created for the new norma package and the process has
  already moved to that directory.  This script will put a template file in the
  directory and initialize the directory as a npm and norma package.

###


Path = require "path"
Fs = require "fs-extra"
Chalk = require "chalk"
Gulp = require "gulp"
_ = require "underscore"

ExecCommand = require "./execute-command"


module.exports = (tasks, cwd) ->

  # cwd = absolute path of directory where package is to be created
  # tasks = [ <appName> ] - flags are not included in the array

  console.log Chalk.green "Creating your package..."

  # PACKAGE-TEMPLATE ----------------------------------------------------

  # __dirname is the directory that the currently executing script resides in
  Fs.copySync(
    Path.resolve __dirname , "./base-package.coffee"
    Path.join process.cwd(), "package.coffee"
  )

  # NORMA.JSON ----------------------------------------------------------

  packageName = tasks[0]

  if packageName.indexOf "#{Tool}-" isnt 0
    packageName = "#{Tool}-#{packageName}"

  config =
    name: packageName
    type: "package"
    main: "package.coffee"
    tasks: {}
    processes: {}

  # Save config
  Fs.writeFileSync(
    Path.join(process.cwd(), "#{Tool}.json")
    JSON.stringify(config, null, 2)
  )

  # PACKAGE.JSON --------------------------------------------------------

  pkgeConfig =
    name: packageName
    version: "0.0.1"
    main: "package.coffee"
    keywords: [
      "norma"
      "gulp"
    ]

  # Save package.json
  Fs.writeFileSync(
    Path.join(process.cwd(), "package.json")
    JSON.stringify(pkgeConfig, null, 2)
  )


  ExecCommand(
    "npm i --save gulp"
    process.cwd()
  ,
    ->
      console.log Chalk.magenta "Package Ready!"
  )

Path = require "path"
Fs = require "fs-extra"
Chalk = require "chalk"
Gulp = require "gulp"
_ = require "underscore"

ExecCommand = require "./execute-command"


module.exports = (tasks, cwd) ->

  console.log Chalk.green "Creating your package..."

  # PACKAGE-TEMPLATE ----------------------------------------------------

  Fs.copySync(
    Path.resolve __dirname , "./base-package.coffee"
    Path.join process.cwd(), "package.coffee"
  )

  # NORMA.JSON ----------------------------------------------------------

  fileName = "#{Tool}.json"
  packageName = tasks[1]

  if packageName.indexOf "#{Tool}-" isnt 0
    packageName = "#{Tool}-#{packageName}"

  config =
  name: packageName
  type: "package"
  tasks: {}
  processes: {}

  # Save config
  Fs.writeFileSync(
    Path.join(process.cwd(), fileName)
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

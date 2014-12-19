
Chalk = require "chalk"
_ = require "underscore"

ReadConfig = require "./read-config"

Add = require "./../methods/add"


module.exports = (tasks, cwd, packages) ->

  Launcher = require "./launcher"

  # set needed variables
  config = ReadConfig cwd
  neededPackages = []

  # If there are not tasks or processes we can't do much, so exit with error
  if !config.tasks and !config.procceses

    err =
      level: "crash"
      message: "#{Tool}.json needs a tasks object or a processes object"
      name: "Not Valid"

    Norma.events.emit "error", err



  # LOOKUP -----------------------------------------------------------------

  # collect all missing tasks into array
  for key of config.tasks
    if packages[key] is undefined
      pkge =
        name: key
        global: config.tasks[key].global
        endpoint: config.tasks[key].endpoint

      neededPackages.push pkge

  # collect all missing procceses into array
  for key of config.processes
    if packages[key] is undefined
      pkge =
        name: key
        global: config.processes[key].global
        endpoint: config.processes[key].endpoint

      neededPackages.push pkge


  # verify unique package (don't download duplicates)
  neededPackges = _.uniq neededPackages

  if neededPackages.length

    # add then run norma again
    Add neededPackages, cwd, ->
      Launcher.run tasks, cwd

    prettyPrint = new Array

    for pkge in neededPackages
      prettyPrint.push pkge.name

    console.log(
      Chalk.green(
        "Installing the following packages:"
      )
      Chalk.magenta "#{prettyPrint.join(', ')}"
    )

    return true

  return false


Chalk = require "chalk"
_ = require "underscore"

Norma = require "./../norma"

module.exports = (cwd, packages, promise) ->

  if !cwd then cwd = process.cwd()

  # set needed variables
  config = Norma.config cwd
  neededPackages = []

  # If there are no tasks so we can't do much, so exit with error
  if !config.tasks

    err =
      level: "crash"
      message: "norma.json needs a tasks object"
      name: "Not Valid"

    Norma.emit "error", err



  # LOOKUP -----------------------------------------------------------------

  # collect all missing tasks into array
  for key of config.tasks
    # @extend "package" handling
    if key.match /@extend/
      extension = key.split("@extend")
      extension = extension[1].trim()
      key = extension
      break



    if packages[key] is undefined
      pkge =
        name: key
        global: config.tasks[key].global
        endpoint: config.tasks[key].endpoint
        dev: config.tasks[key].dev

      neededPackages.push pkge



  # verify unique package (don't download duplicates)
  neededPackges = _.uniq neededPackages

  if neededPackages.length

    packagesCopy = neededPackages.slice()

    # add then run norma again
    Norma.install(packagesCopy, cwd)
      .then( ->
        # Norma.run Norma.args, cwd
        Norma.getPackages(cwd)
          .then( (packages) ->
            promise.resolve(packages)
          )
      )





    prettyPrint = new Array

    for pkge in neededPackages
      prettyPrint.push pkge.name


    msg = Chalk.green("Installing the following packages: ") +
      "#{prettyPrint.join(', ')}"

    Norma.emit "message", msg

    return promise

  else
    return false

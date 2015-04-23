
Chalk = require "chalk"
_ = require "underscore"

Norma = require "./../norma"

module.exports = (cwd, packages, promise) ->


  if !cwd then cwd = process.cwd()

  # set needed variables
  config = Norma.config cwd
  neededPackages = []


  # If there are no tasks so we can't do much, so exit with error
  if !config.tasks and !config.test

    err =
      level: "crash"
      message: "norma.json needs a tasks or test object"
      name: "Not Valid"

    Norma.emit "error", err



  # LOOKUP -----------------------------------------------------------------
  setPackageDetails = (key, _obj, dev) ->

    if not _obj[key]
      return

    # @extend "package" handling
    if _obj[key]["@extend"]
      key = _obj[key]["@extend"]


    if packages[key] is undefined

      if process.env.CI or process.env.production
        if dev or _obj[key].dev
          return

      pkge =
        name: key
        global: _obj[key].global
        endpoint: _obj[key].endpoint
        dev: dev or _obj[key].dev


      neededPackages.push pkge

    return



  # collect all missing tasks into array
  for _task of config.tasks
    setPackageDetails _task, config.tasks



  # collect missing test packages into an array
  if _.isObject config.test
    for _test of config.test

      if _test is "before" or _test is "after"
        continue

      if _test is "main"

        if _.isArray config.test.main
          for item in config.test.main
            setPackageDetails item, config.test.main, true

          return

        _test = config.test.main


      setPackageDetails _test, config.test, true



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

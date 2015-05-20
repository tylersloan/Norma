Path = require "path"
Chalk = require "chalk"
_ = require "underscore"
Q = require "kew"


Norma = require "./../norma"

module.exports = (cwd, packages, promise) ->


  cwd or= process.cwd()

  # set needed variables
  config = Norma.config cwd
  settings = Norma.config Path.join(cwd, ".norma")

  # add temp flag for installation of settings projects
  if settings.tasks
    for task, obj of settings.tasks
      obj.__settings = true

  config.tasks = _.extend config.tasks, settings.tasks


  if settings.test
    for task, obj of settings.test
      obj.__settings = true

  config.test = _.extend config.test, settings.test


  neededPackages = []
  # If there are no tasks so we can't do much, so exit with error
  if not config.tasks and not config.test

    err =
      level: "crash"
      message: "norma file needs a tasks or test object"
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
        settings: _obj[key].__settings

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

    settingsTasks = packagesCopy.filter (x) ->
      x.settings

    packagesCopy = packagesCopy.filter (x) ->
      not x.settings

    logInstalling = (array) ->

      prettyPrint = array.map (x) ->
        return x.name

      msg = Chalk.green("Installing the following packages: ") +
        "#{prettyPrint.join(', ')}"

      Norma.emit "message", msg


    logInstalling neededPackges


    promises = []
    if packagesCopy.length
      promises.push Norma.install(packagesCopy, cwd)

    if settingsTasks.length
      promises.push Norma.install(settingsTasks, Path.join(cwd, ".norma"))

    # add then run norma again
    Q.all(promises)
      .then( ->

        Norma.getPackages(cwd)
          .then( (packages) ->

            promise.resolve(packages)
          )
      )





    return promise

  else
    return false

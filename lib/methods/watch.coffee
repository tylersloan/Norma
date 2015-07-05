
Path = require "path"
Fs = require "fs"
Chalk = require "chalk"
_ = require "underscore"

Norma = require "./../norma"

watching = []
module.exports = (tasks, cwd) ->

  Watch = require "./../utilities/watch"

  cwd or= process.cwd()

  # VARIABLES --------------------------------------------------------------

  config = Norma.config(cwd)
  localConfig = Norma.config(Path.join(cwd, ".norma"))

  # map tasks
  config.tasks = _.extend config.tasks, localConfig.tasks
  # map test
  config.test = _.extend config.test, localConfig.test


  # Store watch started in Norma to span files
  Norma.watchStarted = true

  runTask = (task, cb) ->
    Norma.execute task, ->
      if typeof cb is "function"
        cb null
    return


  ignoreChange = {}
  Norma.ignore = (file, length) ->
    ignoreChange[file] = length


  # WATCH ----------------------------------------------------------------

  # Dynamically generate watch tasks off of runnable tasks
  createWatch = (task) ->

    if Norma.debug
      msg =
        message: "#{task.toUpperCase()}: added to watch"

      Norma.emit "message", msg

    src = if config.tasks[task]? then config.tasks[task].src else "./**/*/"

    taskName = task

    exts = (
      ext.replace(".", "") for ext in Norma.tasks[task].ext
    )

    if exts.length > 1
      exts  = "{#{exts.join(",")}}"
    else
      exts = "#{exts.join(",")}"

    obj = {}

    ###

      Needs of watch API:

      1. ability to close watcher
      2. ability to pass in src
      3. ability to bind event watching functions

    ###
    console.log taskName
    obj[taskName] = Watch([
      "#{src}.#{exts}"
    ], ->
      if Norma.debug
        msg =
          message: "#{task.toUpperCase()}: ready"

        Norma.emit "message", msg
    )

    obj[taskName].events.on("change", (event) ->

      if ignoreChange[event.path] > 0
        ignoreChange[event.path]--
        return

      fileName = Path.basename event.path

      if Norma.verbose
        msg = Chalk.cyan(taskName.toUpperCase()) +
          " saw " +
          Chalk.white(fileName) +
          " was #{event.type}"

        Norma.emit "message", msg

      runTask task, ->
        Norma.emit "file-change", event

    )

    watching.push obj[taskName]





  # START ------------------------------------------------------------------

  if Norma.verbose
    Norma.log "Watching files..."


  Norma.emit "watch-start"

  runnableTasks = []

  groupTasks = []

  for task, options of config.tasks

    if not options.group
      continue

    if typeof options.group is "string"
      options.group = [options.group]

    intersection = _.intersection tasks, options.group

    if intersection.length
      groupTasks.push task

  for task of Norma.tasks
    if not Norma.tasks[task].ext
      continue

    if not config.tasks[task]
      continue

    if not tasks.length
      runnableTasks.push(task)

    else if tasks.indexOf(task) > -1
      runnableTasks.push(task)

  runnableTasks = runnableTasks.concat groupTasks

  Norma.prompt._.autocomplete runnableTasks

  createWatch(task) for task in runnableTasks


  Norma.prompt()

  Norma.prompt.listen (err, line) ->

    if runnableTasks.indexOf(line) > -1
      Norma.emit "message", Chalk.white("Running #{line}")
      runTask line

    return



module.exports.stop = ->

  for watched in watching

    watched.end()

  Norma.prompt.pause()


  return

# API ---------------------------------------------------------------------

module.exports.api = [
  {
    command: ""
    description: "watch for changes"
  }
]

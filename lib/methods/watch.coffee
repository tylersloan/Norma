
Path = require "path"
Fs = require "fs-extra"
Sequence = require "run-sequence"
Chalk = require "chalk"
_ = require "underscore"
Gulp = require "gulp"
Readline = require "readline"
Util = require "util"

ReadConfig = require "./../utilities/read-config"
PkgeLookup = require "./../utilities/package-lookup"
LocalTld = require "./../utilities/local-tld"
Build = require "./build"





module.exports = (tasks, cwd) ->


  # VARIABLES --------------------------------------------------------------

  config = ReadConfig cwd
  prefix = Norma.prefix

  help = [
    "who are you   " + Chalk.grey("introduce myself")
    "help          " + Chalk.grey("display this message.")
    "all           " + Chalk.grey("run a build on all files.")
    "e[xit]        " + Chalk.grey("exit console.")
    "q[uit]        " + Chalk.grey("exit console.")
  ].join("\n")

  completions = ["help", "all", "exit", "quit", "q"]

  runnableTasks = new Array

  for task of Gulp.tasks
    runnableTasks.push(task) if Gulp.tasks[task].ext?

  completions = completions.concat runnableTasks

  # Store watch started in Norma to span files
  Norma.watchStarted = true


  runTask = (task) ->
    Sequence task
    return


  # WATCH ----------------------------------------------------------------

  # Dynamically generate watch tasks off of runnable tasks
  createWatch = (task) ->

    if Norma.debug
      console.log(
        Chalk.red( "Task: #{task.toUpperCase()} added to watch" )
      )

    src = if config.tasks[task]? then config.tasks[task].src else "./**/*/"

    taskName = task

    exts = (
      ext.replace(".", "") for ext in Gulp.tasks[task].ext
    )

    Gulp.watch(
      [
        "#{src}/*.{#{exts}}"
        "!node_modules/**/*"
        "!.git/**/*"
      ], (event) ->


        fileName = Path.basename event.path

        if Norma.verbose
          msg = Chalk.cyan(taskName.toUpperCase()) +
            "saw" +
            Chalk.magenta(fileName) +
            "was #{event.type}"

          Norma.emit "message", msg

        runTask event[task]
        Norma.events.emit 'file-change', event

    )


  # INTERACTIVE -----------------------------------------------------------



  complete = (line) ->

    hits = completions.filter (c) ->
      c  if c.indexOf(line) is 0

    [
      (if hits and hits.length then hits else completions)
      line
    ]



  # PROMPT ----------------------------------------------------------------

  rl = Readline.createInterface(process.stdin, process.stdout, complete)

  prompt = ->
    rl.setPrompt Chalk.grey(prefix), prefix.length
    rl.prompt()


  rl.on("line", (line) ->
    switch line.toLowerCase().trim()
      when "help"
        Util.puts(Chalk.grey(help))
      when "who are you"
        console.log Chalk.green("I am Norma!")
      when "i just want to build websites"
        console.log Chalk.green("I can help with that!")
      when "exit", "e", "quit", "q"
        rl.close()
      when "all"
        Build []
      else
        if runnableTasks.indexOf(line) > -1
          Norma.emit "message", Chalk.grey("Running #{line}")
          runTask line

    prompt()
    return

  ).on( "close", ->

    Norma.emit "message", "Have a great day!"
    Norma.stop()
    return

  )

  # START ------------------------------------------------------------------

  do ->

    if Norma.verbose
      msg =
        message: "Watching files..."
        color: "grey"

      Norma.emit "message", msg

    prompt()

    for task of Gulp.tasks
      createWatch(task) if Gulp.tasks[task].ext?


    Norma.emit 'watch-start'

    return



# API ---------------------------------------------------------------------

module.exports.api = [
  {
    command: ""
    description: "watch for changes"
  }
  {
    command: "--open"
    description: "open your browser to site"
  }
  {
    command: "--editor"
    description: "open your editor to current project root"
  }
]

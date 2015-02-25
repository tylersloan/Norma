
Readline = require "readline"
Util = require "util"
Chalk = require "chalk"
_ = require "underscore"

Norma = require "./../norma"



# HELP --------------------------------------------------------------------

help = [
  "who are you   " + Chalk.grey("introduce myself")
  "help          " + Chalk.grey("display this message.")
  "all           " + Chalk.grey("run a build on all files.")
  "e[xit]        " + Chalk.grey("exit console.")
  "q[uit]        " + Chalk.grey("exit console.")
]



addHelp = (terms) ->

  if !terms.length
    return

  help = _.union help, terms

  return


# AUTOCOMPLETE -----------------------------------------------------------

autocomplete = ["help", "all", "exit", "quit", "q"]

complete = (terms) ->

  if !terms.length
    return

  autocomplete = _.union autocomplete, terms

  return


# INTERACTIVE ------------------------------------------------------------

interactive = (line) ->

  hits = autocomplete.filter (c) ->
    c  if c.indexOf(line) is 0

  [
    (if hits and hits.length then hits else autocomplete)
    line
  ]



# INIT -----------------------------------------------------------------

rl = {}

initialize = ->

  rl = Readline.createInterface(
    process.stdin, process.stdout, interactive
  )

  # EVENTS -------------------------------------------------------------

  rl.on("line", (line) ->
    switch line.toLowerCase().trim()
      when "help"
        Util.puts(Chalk.grey(help.join("\n")))
      when "exit", "e", "quit", "q"
        rl.close()
      when "all"
        Build []
      when "open the pod bay doors"
        name = Norma.settings.get "user:name"
        if name then name = ", " + name else name = ""
        Norma.emit(
          "message"
          "I'm sorry#{name}. I'm afraid I can't do that."
        )

    prompt()
    return

  ).on( "close", ->
    Norma.prompt.open = false
    Norma.emit "message", "Have a great day!"
    Norma.close()
    return

  )

  Norma.prompt._.initialized = true



# PROMPT ----------------------------------------------------------------

prompt = ->

  if !Norma.prompt._.initialized
    initialize()

  rl.setPrompt Chalk.grey(Norma._.prefix), Norma._.prefix.length
  rl.prompt()

  Norma.prompt.open = true



# LISTEN ------------------------------------------------------------------

listen = (cb) ->

  if typeof cb isnt "function"
    return

  if !Norma.prompt._.initialized
    Norma.emit "message", "prompt not initiatied"
    cb "prompt not initiatied"
    return

  rl.on "line", (line) ->
    cb null, line

  return



# PAUSE ------------------------------------------------------------------

pause = ->

  if !Norma.prompt._.initialized
    Norma.emit "message", "prompt not initiatied"
    return

  Norma.prompt.open = false
  rl.pause()


  return



module.exports = prompt
module.exports._ =
  help: addHelp
  autocomplete: complete
  initialized: false

module.exports.listen = listen
module.exports.pause = pause

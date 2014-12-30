Readline = require "readline"
Util = require "util"
Chalk = require "chalk"

module.exports = ->

  prefix = "Ø "

  # UTIL ------------------------------------------------------------------

  help = [
    "who are you   " + Chalk.grey("introduce myself")
    "help          " + Chalk.grey("display this message.")
    "all           " + Chalk.grey("run a build on all files.")
    "e[xit]        " + Chalk.grey("exit console.")
    "q[uit]        " + Chalk.grey("exit console.")
  ].join("\n")

  complete = (line) ->
    completions = "help all exit quit q".split(" ")

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

    prompt()
    return
  ).on "close", ->
    console.log Chalk.grey "Have a great day!"
    process.exit 0
    return



  # START ------------------------------------------------------------------

  do ->
    prompt()
    return

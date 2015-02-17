Exec = require('child_process').exec


module.exports = (tasks, cwd) ->

  # ERROR -------------------------------------------------------------------

  # User tried to run `norma add` without argument
  if !tasks.length

    err =
      level: "crash"
      name: "Missing Info"
      message: "Please specify a package or scaffold to search for"

    Norma.events.emit "error", err

    return

  # convert to norma- search term
  for task in tasks
    if !task.match /^norma(-|\.)/
      tasks[_i] = "norma-#{task}"

  exit = ->
    msg =
      message: "No response from NPM after 30s. Looks like there may be a connection issue or a long task being run. To exit norma, press ctrl + c"
      level: "log"

    Norma.emit "error", msg



  timeout = setTimeout exit, 30000


  Norma.events.emit "message", "searching..."

  child = Exec("npm search #{tasks}", (err, stdout, stderr) ->

    throw err if err

  )

  child.stdout.setEncoding("utf8")

  child.stdout.on "data", (data) ->

    clearTimeout timeout

    str = data.toString()
    lines = str.split(/(\r?\n)/g)

    i = 0
    while i < lines.length
      if !lines[i].match "\n"
        message = lines[i].split("] ")

        if message.length > 1
          message.splice(0, 1)

        message = message.join(" ")

        Norma.emit "message", message
      i++

    return





# API ----------------------------------------------------------------------

module.exports.api = [
  {
    command: "<search-term>"
    description: "search npm for package or scaffold details"
  }
]

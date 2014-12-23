Npm = require "npm"

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
    err = new Error(
      "No response from NPM after 10s. Looks like there may be a connection issue"
    )

    err.level = "crash"

    Norma.events.emit "error", err



  setTimeout exit, 10000

  # Run npm tasks within load per API found here:
  # https://docs.npmjs.com/api/load
  Npm.load( ->
    Norma.events.emit "message", "searching..."
    Npm.commands.search(tasks, (result) ->
      process.exit 0
    )
  )



# API ----------------------------------------------------------------------

module.exports.api = [
  {
    command: "<search-term>"
    description: "search npm for package or scaffold details"
  }
]

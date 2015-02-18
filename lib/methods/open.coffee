
Open = require "open"


module.exports = (tasks, cwd) ->

  # User tried to run `norma add` without argument
  if !tasks.length
    editor = Norma.getSettings.get "user:editor"

    if !editor
      msg = "no editor specified, to add one run" +
        "`norma config user:editor <editor> --global`"

      Norma.emit "message", msg

      Norma.emit "stop"

  else
    editor = tasks[0]

  Open cwd, editor



# API ----------------------------------------------------------------------

module.exports.api = [
  {
    command: ""
    description: "open project in preferred editor"
  }
  {
    command: "<editor-name>"
    description: "open project in specified editor"
  }
]

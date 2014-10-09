
Gulp = require "gulp"



module.exports = (tasks, cwd) ->

  Build = require("./build")(tasks, cwd)

  process.nextTick( ->
    Gulp.start ["server"]
  )


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

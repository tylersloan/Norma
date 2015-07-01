
###

  Borrowed from Gulp who also uses Liftoff for completions
  https://github.com/gulpjs/gulp-cli/blob/ddec6f645a6d2691ced7a5176a8092415d93697f/lib/completion.js

###

Fs = require("fs")
Path = require("path")

module.exports = (name) ->

  if typeof name isnt "string"
    throw new Error("Missing completion type")

  file = Path.join(__dirname, "../logging/", name)

  try
    console.log Fs.readFileSync(file, "utf8")
    process.exit 0
  catch err
    console.log(
      'echo "norma autocompletion rules for \'#{name}\' not found"'
    )
    process.exit 5
  return

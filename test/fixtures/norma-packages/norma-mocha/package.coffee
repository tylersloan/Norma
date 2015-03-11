Path        = require "path"
Norma       = require "../../../../lib/index"
Clipboard   = require "gulp-clipboard"




module.exports = (config, name) ->

  # console.log config.tasks[name]
  # CONFIG ----------------------------------------------------------------
  if !name then name = "mocha"

  # can be required in tasks or test
  if config.test and config.test[name]
    options = config.test[name]
  else
    options = config.tasks[name]


  src = Path.normalize(options.src)
  dest = Path.normalize(options.dest)


  # order
  if options.order
    order = options.order
  else
    order = "post"

  # ext
  if !options.ext
    options.ext = "*"

  if typeof options.ext is "string"
    options.ext = [options.ext]


  extType = options.ext.map( (ext) ->
    return ext.replace(".", "").trim()
  )


  # #{name}-COMPILE ----------------------------------------------------------

  Norma.task "#{name}-compile", (cb) ->

    if extType.length > 1
      extType  = "{#{extType.join(",")}}"

    # Make sure other files and folders are copied over
    Norma.src([
      src + ".#{extType}"
    ])
      .pipe Clipboard()
      .pipe Norma.dest(dest)

    cb null



  # COPY ------------------------------------------------------------------
  Norma.task "#{name}", (cb) ->

    Norma.execute "#{name}-compile", ->

      Norma.log "#{name}: ✔ All done!"


    cb null
    return



  if options.type
    Norma.tasks["#{name}"].type = options.type

  Norma.tasks["#{name}"].order = order
  Norma.tasks["#{name}"].ext = options.ext

  module.exports.tasks = Norma.tasks

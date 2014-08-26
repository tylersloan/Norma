path        = require("path")
chalk       = require("chalk")
sequence    = require("run-sequence")
gulp        = require("gulp")
flags       = require("minimist")(process.argv.slice(2))
gutil       = require "gulp-util"
browserSync = require "browser-sync"
fs          = require "fs"
packageLoc  = path.dirname(fs.realpathSync(__filename)) + "/../package.json"
$           = require("gulp-load-plugins")({config: packageLoc})



# CONFIG ---------------------------------------------------------------------


config = require("../lib/config/config")(process.cwd())

unless config.javascript?
  configFound = false
  config.src = './'
  config.dest = './'
else
  configFound = true
  config.src = path.normalize(config.javascript.src)
  config.dest = path.normalize(config.javascript.dest)



# FLAGS ----------------------------------------------------------------------

isProduction = flags.production or flags.prod or false



# JAVASCRIPT-CLEAN -----------------------------------------------------------

gulp.task "javascript-clean", (cb) ->

  # Remove export folder and files
  gulp.src([
    config.dest
  ],
    read: false
  ).pipe $.rimraf(force: true)

  cb null



# JAVASCRIPT-TEST ------------------------------------------------------------


handleError = (err) ->
  console.log(err.toString())
  unless isProduction
    this.emit("end")


gulp.task "javascript-test", (cb) ->


  gulp.src([
      config.src + "/**/*.{js,coffee}"
    ], {read: false})
    .pipe $.plumber()
    # .pipe $.exec("./node_modules/.bin/mocha --compilers=coffee:coffee-script/register --reporter=spec <%= file.path %>")
    # .pipe $.exec.reporter()
    # .on( "error", $.notify.onError( title: "Mocha ☕", message: "HAS ERRORS" ))
    .on("error", handleError)

  cb null


# JAVASCRIPT-HINT ------------------------------------------------------------

gulp.task "javascript-hint",  (cb) ->

  gulp.src([
    config.src + "/**/*.{js,coffee}"
    ])
    .pipe $.changed(config.dest, { extension: ".js" })
    .pipe $.plumber()
    .pipe $.coffeelint()
    .pipe $.coffeelint.reporter()
    .on( "error", $.notify.onError( title: "CoffeeLint", message: "HAS ERRORS" ))
    .on("error", gutil.log)

  cb null


# JAVASCRIPT-COMPILE ---------------------------------------------------------

gulp.task "javascript-compile", ["javascript-hint"], (cb) ->

  # Proccess Scripts
  gulp.src([
      config.src + "/**/*.{js,coffee}"
    ])
    .pipe $.changed(config.dest, { extension: ".js" })
    .pipe $.plumber()
    .pipe( $.tap( (file, t) ->

      if path.extname(file.path) is ".coffee"

        return t.through $.coffee, [{bare: true}]

    ))
    .pipe( $.if(isProduction, $.replace(/(\/\/)?(console\.)?log\((.*?)\);?/g, "")))
    .pipe $.if(isProduction, $.uglify(), $.beautify())
    .pipe gulp.dest(config.dest)
    .pipe $.filesize()
    .on("error", gutil.log)

  cb null



# JAVASCRIPT -----------------------------------------------------------------

gulp.task "javascript", (cb) ->


  unless gulp.lrStarted or !configFound
    sequence "javascript-clean", "javascript-compile",	->

      console.log chalk.green("Javascript: ✔ All done!")

      return
  else
    sequence "javascript-compile", ->

      console.log chalk.green("Javascript: ✔ All done!")

  cb null

gulp.tasks["javascript"].ext = [".js", ".coffee"]

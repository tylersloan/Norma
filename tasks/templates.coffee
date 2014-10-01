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

config = require("../lib/methods/read-config")(process.cwd())

unless config.templates?
  configFound = false
  config.src = './'
  config.dest = './'
else
  configFound = true
  config.src = path.normalize(config.templates.src)
  config.dest = path.normalize(config.templates.dest)



# FLAGS ----------------------------------------------------------------------

isProduction = flags.production or flags.prod or false



# TEMPLATES-CLEAN ------------------------------------------------------------

gulp.task "templates-clean", (cb) ->

  # Remove export folder and files
  gulp.src([
    config.dest
  ],
    read: false
  ).pipe $.rimraf(force: true)

  cb null



# TEMPLATES-COMPILE ----------------------------------------------------------

gulp.task "templates-compile", (cb) ->

  gulp.src([
    config.src + "/**/*.{html, ejs, handlebars}"
    ])
    .pipe $.changed(config.dest)
    .pipe $.plumber()
    .pipe $.htmlmin({
      collapseWhitespace: true
      removeComments : true
      minifyJS : true
      minifyCSS : true
    })
    .pipe $.clipboard()
    .pipe gulp.dest(config.dest)
    .pipe $.if(gulp.lrStarted, browserSync.reload({stream:true}))

  cb null



# TEMPLATES ------------------------------------------------------------------

gulp.task "templates", (cb) ->

  unless gulp.lrStarted or !configFound
    sequence "templates-clean", "templates-compile",	->

      console.log chalk.green("Templates: ✔ All done!")

      return
  else
    sequence "templates-compile", ->

      console.log chalk.green("Templates: ✔ All done!")

  cb null


gulp.tasks["templates"].ext = [".html", ".ejs", ".handlebars"]

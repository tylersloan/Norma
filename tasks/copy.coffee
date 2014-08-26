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

unless config.copy?
  console.log(
    chalk.red("No copy task found in nspfile...aborting")
  )
  process.exit 0

config.src = path.normalize(config.copy.src)
config.dest = path.normalize(config.copy.dest)



# COPY-COMPILE ---------------------------------------------------------------

gulp.task "copy-compile", (cb) ->


  extType = config.copy.ext.map( (ext) ->
    return ext.replace(".", "").trim()
  )

  extType  = extType.join(",")
  # Make sure other files and folders are copied over
  gulp.src([
    config.src + "/**/*.{" + extType + "}"
  ])
    .pipe $.plumber()
    .pipe $.clipboard()
    .pipe gulp.dest(config.dest)

  cb null



# COPY -----------------------------------------------------------------------

gulp.task "copy", (cb) ->

  sequence "copy-compile", ->

    console.log chalk.green("Copy: ✔ All done!")

  cb null
  return


gulp.tasks["copy"].ext = config.copy.ext
gulp.tasks["copy"].order = "post"

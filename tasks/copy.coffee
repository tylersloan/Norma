path       = require("path")
globule    = require("globule")
chalk      = require("chalk")
sequence   = require("run-sequence")
gulp       = require("gulp")
flags      = require("minimist")(process.argv.slice(2))
gutil      = require 'gulp-util'
watch      = require 'gulp-watch'
browserSync = require 'browser-sync'
fs         = require "fs"
packageLoc = path.dirname(fs.realpathSync(__filename)) + '/../package.json'
plugins    = require('gulp-load-plugins')({config: packageLoc})


cwd = process.cwd()

config     = require('../lib/config/config')(cwd)


# FLAGS ----------------------------------------------------------------------

lrDisable = flags.nolr or false
isProduction = flags.production or flags.prod or false
env = if flags.production or flags.prod then 'production' else 'development'

unless config.copy?
  console.log(
    chalk.red("No copy task found in nspfile...aborting")
  )
  process.exit 0


config.src = path.normalize(config.copy.src)
config.dest = path.normalize(config.copy.dest)


gulp.task 'copy', (cb) ->

  sequence 'copy-compile', ->

    console.log chalk.green("Copy: ✔ All done!")

  cb null
  return



gulp.tasks['copy'].ext = config.copy.ext
gulp.tasks['copy'].type = 'async'
gulp.tasks['copy'].order = 'post'



# TEMPLATES -------------------------------------------------------------------


gulp.task('copy-compile', (cb) ->


  extType = config.copy.ext.map( (ext) ->
    return ext.replace('.', '').trim()
  )

  extType  = extType.join(',')
  # Make sure other files and folders are copied over
  gulp.src([
    config.src + "/**/*.{" + extType + "}"
  ])
    .pipe plugins.plumber()
    .pipe plugins.clipboard()
    .pipe gulp.dest(config.dest)

  cb null
  return
)

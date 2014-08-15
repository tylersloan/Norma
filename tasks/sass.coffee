path       = require("path")
globule    = require("globule")
chalk      = require("chalk")
sequence   = require("run-sequence")
gulp       = require("gulp")
plugins    = require('gulp-load-plugins')()
flags      = require("minimist")(process.argv.slice(2))
gutil      = require 'gulp-util'
watch      = require 'gulp-watch'


cwd = process.cwd()

config     = require('../lib/config/config')(cwd)


# FLAGS ----------------------------------------------------------------------

lrDisable = flags.nolr or false
isProduction = flags.production or flags.prod or false
env = if flags.production or flags.prod then 'production' else 'development'

lrStarted = false


gulp.task 'sass', () ->

  config.src = path.normalize(config.sass.src)
  config.dest = path.normalize(config.sass.dest)


  sequence "sass-clean", "sass-compile",  ->

    console.log chalk.green("Sass: ✔ All done!")

    return

gulp.tasks['sass'].ext = ['.css', '.sass', '.scss']

# CLEAN ----------------------------------------------------------------------

gulp.task "sass-clean", (cb) ->

  # Remove export folder and files
  gulp.src([
    config.dest
  ],
    read: false
  ).pipe plugins.rimraf(force: true)



# SASS -----------------------------------------------------------------------

gulp.task "sass-compile", ( cb) ->


  minify = if config.sass.minify or isProduction then true else false
  # Process the .scss files
  # While serving, this task opens a continuous watch
  return (
    unless lrStarted
      gulp.src([
          config.src + '/**/*.{scss, css, sass}'
        ])
    else
      watch(
        glob: [config.src + '/**/*.{scss, css, sass}']
        emitOnGlob: false
        name: "stylesheets"
        silent: true
      )
    )
		.pipe plugins.plumber()
		.pipe plugins.sass({
			errLogToConsole: true
		})
		.pipe plugins.combineMediaQueries()
		.pipe plugins.cssValidator({
			logWarnings: true
		}).on('error', gutil.log)
		.pipe plugins.autoprefixer(
      "last 2 version",
      "safari 5",
      "ie 9",
      "opera 12.1",
      "ios 6",
      "android 4"
    )
    .pipe plugins.if(minify, plugins.minifyCss())
		.pipe gulp.dest(config.dest)
		.on('error', gutil.log)


  # Continuous watch never ends, so end it manually
  cb null if lrStarted

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

unless config.sass?
	configFound = false
	config.src = '.'
	config.dest = '.'
	config.sass =
		minify: true
else
	configFound = true
	config.src = path.normalize(config.sass.src)
	config.dest = path.normalize(config.sass.dest)



# FLAGS ----------------------------------------------------------------------

isProduction = flags.production or flags.prod or false



# SASS-CLEAN -----------------------------------------------------------------

gulp.task "sass-clean", (cb) ->

	# Remove export folder and files
	gulp.src([
		config.dest
	],
		read: false
	).pipe $.rimraf(force: true)

	cb null



# SASS-COMPILE ---------------------------------------------------------------

gulp.task "sass-compile", ( cb) ->

	minify = if config.sass.minify or isProduction then true else false

	gulp.src([
     config.src + "/**/*.{scss, css, sass}"
   ])
		.pipe $.plumber()
		.pipe $.sass({
			errLogToConsole: true
		})
		.pipe $.combineMediaQueries()
		.pipe $.cssValidator({
			logWarnings: true
		}).on("error", gutil.log)
		.pipe $.autoprefixer(
			"last 2 version",
			"safari 5",
			"ie 9",
			"opera 12.1",
			"ios 6",
			"android 4"
		)
		.pipe $.if(minify, $.minifyCss())
		# .pipe $.if(!isProduction, $.filesize())
		.pipe gulp.dest(config.dest)
    .pipe $.if(gulp.lrStarted, browserSync.reload({stream:true}))
		.on("error", gutil.log)

	cb null



# SASS -----------------------------------------------------------------------

gulp.task "sass", (cb) ->

	unless gulp.lrStarted or !configFound
		sequence "sass-clean", "sass-compile",	->

			console.log chalk.green("Sass: ✔ All done!")

			return
	else
		sequence "sass-compile", ->

			console.log chalk.green("Sass: ✔ All done!")

	cb null

gulp.tasks["sass"].ext = [".css", ".sass", ".scss"]

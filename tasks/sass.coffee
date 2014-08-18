path			 = require("path")
globule		= require("globule")
chalk			= require("chalk")
sequence	 = require("run-sequence")
gulp			 = require("gulp")
flags			= require("minimist")(process.argv.slice(2))
gutil			= require 'gulp-util'
watch			= require 'gulp-watch'
browserSync = require 'browser-sync'
fs				 = require "fs"
packageLoc = path.dirname(fs.realpathSync(__filename)) + '/../package.json'
plugins		= require('gulp-load-plugins')({config: packageLoc})

cwd = process.cwd()

config		 = require('../lib/config/config')(cwd)


# FLAGS ----------------------------------------------------------------------

lrDisable = flags.nolr or false
isProduction = flags.production or flags.prod or false
env = if flags.production or flags.prod then 'production' else 'development'


unless config.sass?
	console.log(
		chalk.red("No sass task found in nspfile...aborting")
	)
	process.exit 0

config.src = path.normalize(config.sass.src)
config.dest = path.normalize(config.sass.dest)

gulp.task 'sass', (cb) ->

	unless gulp.lrStarted
		sequence "sass-clean", "sass-compile",	->

			console.log chalk.green("Sass: ✔ All done!")

			return
	else
		sequence 'sass-compile', ->

      console.log chalk.green("Sass: ✔ All done!")

	cb null

gulp.tasks['sass'].ext = ['.css', '.sass', '.scss']



# CLEAN ----------------------------------------------------------------------

gulp.task "sass-clean", (cb) ->

	# Remove export folder and files
	gulp.src([
		config.dest
	],
		read: false
	).pipe plugins.rimraf(force: true)

	cb null



# SASS -----------------------------------------------------------------------

gulp.task "sass-compile", ( cb) ->

	minify = if config.sass.minify or isProduction then true else false

	gulp.src([
     config.src + '/**/*.{scss, css, sass}'
   ])
		.pipe plugins.plumber()
		.pipe plugins.sass({
			errLogToConsole: true
		})
		.pipe plugins.combineMediaQueries()
		# .pipe plugins.cssValidator({
		# 	logWarnings: true
		# }).on('error', gutil.log)
		.pipe plugins.autoprefixer(
			"last 2 version",
			"safari 5",
			"ie 9",
			"opera 12.1",
			"ios 6",
			"android 4"
		)
		.pipe plugins.if(minify, plugins.minifyCss())
		# .pipe plugins.if(!isProduction, plugins.filesize())
		.pipe gulp.dest(config.dest)
    .pipe plugins.if(gulp.lrStarted, browserSync.reload({stream:true}))
		.on('error', gutil.log)

	cb null

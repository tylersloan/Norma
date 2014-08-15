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




gulp.task 'templates', () ->

  config.src = path.normalize(config.templates.src)
  config.dest = path.normalize(config.templates.dest)


  sequence "templates-clean", "templates-compile",  ->

    console.log chalk.green("Templates: ✔ All done!")

    return

gulp.tasks['templates'].ext = ['.html', '.ejs', '.handlebars']

# CLEAN ----------------------------------------------------------------------

gulp.task "templates-clean", (cb) ->

  # Remove export folder and files
  gulp.src([
    config.dest
  ],
    read: false
  ).pipe plugins.rimraf(force: true)



# TEMPLATES -------------------------------------------------------------------


gulp.task('templates-compile', (cb) ->

  gulp.src([
    config.src + '/**/*.{html, ejs, handlebars}'
    ])
    .pipe plugins.changed(config.dest)
    .pipe plugins.plumber()
    .pipe plugins.htmlmin({
      collapseWhitespace: true
      removeComments : true
      minifyJS : true
      minifyCSS : true
    })
    .pipe plugins.clipboard()
    .pipe gulp.dest(config.dest)

)

path       = require "path"
globule    = require "globule"
chalk      = require "chalk"
sequence   = require "run-sequence"
gulp       = require "gulp"
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




gulp.task 'javascript', () ->

  config.src = path.normalize(config.javascript.src)
  config.dest = path.normalize(config.javascript.dest)


  sequence "javascript-clean", "javascript-compile",  ->

    console.log chalk.green("Javascript: ✔ All done!")

    return

gulp.tasks['javascript'].ext = ['.js', '.coffee']


# CLEAN ----------------------------------------------------------------------

gulp.task "javascript-clean", (cb) ->

  # Remove export folder and files
  gulp.src([
    config.dest
  ],
    read: false
  ).pipe plugins.rimraf(force: true)


# SCRIPTS ---------------------------------------------------------------------


handleError = (err) ->
  console.log(err.toString())
  unless isProduction
    this.emit('end')


gulp.task 'javascript-test', (cb) ->


  gulp.src([
      config.src + '/**/*.{js,coffee}'
    ], {read: false})
    .pipe plugins.plumber()
    # .pipe plugins.exec('./node_modules/.bin/mocha --compilers=coffee:coffee-script/register --reporter=spec <%= file.path %>')
    # .pipe plugins.exec.reporter()
    # .on( 'error', plugins.notify.onError( title: 'Mocha ☕', message: 'HAS ERRORS' ))
    .on('error', handleError)



gulp.task 'javascript-hint',  (cb) ->

  gulp.src([
    config.src + '/**/*.{js,coffee}'
    ])
    .pipe plugins.changed(config.dest, { extension: '.js' })
    .pipe plugins.plumber()
    .pipe plugins.coffeelint()
    .pipe plugins.coffeelint.reporter()
    .on( 'error', plugins.notify.onError( title: 'CoffeeLint', message: 'HAS ERRORS' ))
    .on('error', gutil.log)




gulp.task 'javascript-compile', ['javascript-hint'], (cb) ->

  # Proccess Scripts
  gulp.src([
      config.src + '/**/*.{js,coffee}'
    ])
    .pipe plugins.changed(config.dest, { extension: '.js' })
    .pipe plugins.plumber()
    .pipe( plugins.tap( (file, t) ->

      if path.extname(file.path) is '.coffee'

        return t.through plugins.coffee, [{bare: true}]

    ))
    .pipe( plugins.if(isProduction, plugins.replace(/(\/\/)?(console\.)?log\((.*?)\);?/g, '')))
    .pipe plugins.if(isProduction, plugins.uglify(), plugins.beautify())
    .pipe gulp.dest(config.dest)
    # .pipe plugins.filesize()
    .on('error', gutil.log)

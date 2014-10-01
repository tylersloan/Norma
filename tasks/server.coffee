path        = require "path"
globule     = require "globule"
chalk       = require "chalk"
sequence    = require "run-sequence"
gulp        = require "gulp"
flags       = require("minimist")(process.argv.slice(2))
gutil       = require 'gulp-util'
browserSync = require 'browser-sync'
fs          = require "fs"
packageLoc  = path.dirname(fs.realpathSync(__filename)) + '/../package.json'
plugins     = require('gulp-load-plugins')({config: packageLoc})
util        = require './util'
nconf       = require 'nconf'




# VARS -----------------------------------------------------------------------

cwd = process.cwd()
lrStarted = false
isProduction = (flags.production or flags.p) or false
isServe = (flags.serve or flags.s) or false
isOpen = (flags.open or flags.o) or false
isEdit = (flags.edit or flags.e) or false
isVerbose = flags.verbose or false
isTunnel = (flags.tunnel or flags.t) or false
tunnelUrl = null
isPSI = flags.psi or false
config		 = require('../lib/methods/read-config')(cwd)
isProxy = if config.proxy then true else false
connection = {}
configFile = '.' + Tool


# .NSPCONFIG -----------------------------------------------------------------

# Lets see if there are custom local configs overwrites
configExists = fs.existsSync path.join(process.cwd(), configFile)

useDir = if configExists then process.cwd() else path.resolve(__dirname, '../')

# load master config in case local doesn't have the data we need
masterConfig = JSON.parse(fs.readFileSync(
	path.join(path.resolve(__dirname, '../'), configFile), {encoding: 'utf8'}
))

# Use nconf to load the data
nconf
	.file('project', {
		file: '.#{Tool}',
		dir: useDir,
		search: true
	})

if nconf.get('project:host')?
	host = nconf.get('project:host')
else
	host = path.basename(process.cwd())



# SERVER ---------------------------------------------------------------------
#
gulp.task "server", ["browsersync"],	(cb) ->


	# Dynamically generate watch tasks off of runnable tasks
	createWatch = (task) ->
		if config[task]
			src = config[task].src
		else
			src = './'
		taskName = task
		exts = gulp.tasks[task].ext.map( (ext) ->
			return ext.replace('.', '')
		)
		plugins.watch
			glob: [src + "**/*.{" + exts + "}"]
			emitOnGlob: false
			name: taskName.toUpperCase()
			silent: true
		, ->
			console.log(chalk.cyan("☞	Running task \"" + taskName + "\""))
			sequence taskName, browserSync.reload
			return


	for task of gulp.tasks
		if gulp.tasks[task].ext?

			createWatch(task)





gulp.task "browsersync", (cb) ->

	serverOpts =
		server:
			baseDir: if config.root? then path.normalize(config.root) else process.cwd()
			middleware: [
				(req, res, next) ->
					# console.log(req, res)
					next()
			]
		logLevel : "silent"


	if isProxy
		serverOpts["host"] = host

	# Serve files and connect browsers
	browserSync.init null, serverOpts, (err, data) ->
		if err isnt null
			console.log chalk.red("✘	Setting up a local server failed... Please try again. Aborting.\n") + chalk.red(err)
			process.exit 0


		connection.external = data.options.external
		connection.port = data.options.port


		# Store lr in Gulp to span files
		gulp.lrStarted = true

		# Show some logs
		console.log chalk.cyan("🌐	Local access at"), chalk.magenta(data.options.urls.local)
		console.log chalk.cyan("🌐	Network access at"), chalk.magenta(data.options.urls.external)


		#Process flags
		util.openBrowser(data.options.urls.local)	if isOpen
		util.openEditor(process.cwd())	if isEdit
		# gulp.start "tunnel"	if isTunnel
		# if isPSI
		# 	 isTunnel = true
		# 	 gulp.start "psi"
		# return

	cb null
	return

# NGROK ----------------------------------------------------------------------
#
# https://ngrok.com
# gulp.task "tunnel", (cb) ->
#
# 	# Quit this task if no flag was set or if the url is already set to
# 	# prevent a "task completion callback called too many times" error
# 	if not isTunnel or tunnelUrl isnt null
# 		cb null
# 		return
# 	console.log chalk.grey("☞	Tunneling local server to the web...")
# 	verbose chalk.grey("☞	Running task \"tunnel\"")
#
# 	# Expose local server to web through tunnel
# 	# with Ngrok
# 	ngrok.connect connection.port, (err, url) ->
#
# 		# If there was an error, log it and exit
# 		if err isnt null
# 			console.log chalk.red("✘	Tunneling failed, please try again. Aborting.\n") + chalk.red(err)
# 			process.exit 0
# 		tunnelUrl = url
# 		console.log chalk.cyan("🌐	Public access at"), chalk.magenta(tunnelUrl)
# 		cb null
# 		return
#
# 	return
#
#
# # PAGESPEED INSIGHTS ---------------------------------------------------------
# #
# gulp.task "psi", ["tunnel"], (cb) ->
#
# 	# Quit this task if no flag was set
# 	unless isPSI
# 		cb null
# 		return
#
# 	# Quit this task if ngrok somehow didn't run correctly
# 	if tunnelUrl is null
# 		console.log chalk.red("✘	Running PSI cancelled because Ngrok didn't initiate correctly...")
# 		cb null
# 		return
# 	verbose chalk.grey("☞	Running task \"psi\"")
# 	console.log chalk.grey("☞	Running PageSpeed Insights...")
#
# 	# Define PSI options
# 	opts =
# 		url: tunnelUrl
# 		strategy: flags.strategy or "desktop"
# 		threshold: 80
#
#
# 	# Set the key if one was passed in
# 	console.log chalk.yellow.inverse("Using a key is not yet supported as it just crashes the process. For now, continue using `--psi` without a key.")	if !!flags.key and _.isString(flags.key)
#
# 	# TODO: Fix key
# 	#opts.key = flags.key;
#
# 	# Run PSI
# 	psi opts, (err, data) ->
#
# 		# If there was an error, log it and exit
# 		if err isnt null
# 			console.log chalk.red("✘	Threshold of " + opts.threshold + " not met with score of " + data.score)
# 		else
# 			console.log chalk.green("✔	Threshold of " + opts.threshold + " exceeded with score of " + data.score)
# 		cb null
# 		return
#
#
# 	# Since psi throw's the threshold error,
# 	# we have to listen for it process-wide (bad!) — ONCE
# 	process.once "uncaughtException", (err) ->
# 		console.log chalk.red(err)
# 		return
#
# 	return

open = require 'open'
nconf = require 'nconf'
chalk = require 'chalk'
fs = require 'fs-extra'
path = require 'path'


# Lets see if there are custom local configs overwrites
configExists = fs.existsSync path.join(process.cwd(), '.nspconfig')

useDir = if configExists then process.cwd() else path.resolve(__dirname, '../')

# load master config in case local doesn't have the data we need
masterConfig = JSON.parse(fs.readFileSync(
	path.join(path.resolve(__dirname, '../'), '.nspconfig'), {encoding: 'utf8'}
))

# Use nconf to load the data
nconf
	.file('project', {
		file: '.nspconfig',
		dir: useDir,
		search: true
	})



if nconf.get('user:browser')
	browser = nconf.get('user:browser')
else
	browser = masterConfig.user.browser


if nconf.get('user:editor')
	editor = nconf.get('user:editor')
else
	editor = masterConfig.user.editor

# console.log browser

openBrowser = (location)->

	console.log(chalk.cyan("Opening"),
		chalk.magenta(location),
		chalk.cyan("in"),
		chalk.magenta(browser)
	)

	if browser is `undefined`
		console.log(chalk.red('No browser configured. Add browser to nsp config'))
		console.log(chalk.red('`nsp config user:browser yourbrowserhere`'))
	else
	  open location, browser


# Open files in editor
openEditor = (cwd) ->

	console.log(chalk.cyan("Opening"),
		chalk.magenta(cwd),
		chalk.cyan("in"),
		chalk.magenta(editor)
	)

	if editor is `undefined`
		console.log(chalk.red('No editor configured. Add editor to nsp config'))
		console.log(chalk.red('`nsp config user:editor youreditorhere`'))
	else
		open cwd, editor



module.exports.openBrowser = openBrowser
module.exports.openEditor = openEditor

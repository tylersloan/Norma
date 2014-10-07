Path = require "path"
Exec = require('child_process').exec
Chalk = require 'chalk'
Flags = require('minimist')( process.argv.slice(2) )
Ghdownload = require("github-download")

# norma add --scaffold <git repo>
module.exports = (tasks, cwd) ->

	if tasks.length is 1

		console.log Chalk.red "Please specify a task or --scaffold <repo>"

		process.exit 0

	if Flags.scaffold
		tasks[1] = Flags.scaffold

		finalLoc = tasks[1].split('norma-')
		finalLoc = finalLoc[1]
		scaffoldLocation = Path.resolve __dirname, "../../scaffolds/", finalLoc


		Ghdownload(
		  tasks[1]
			scaffoldLocation + "/"
		).on "end", ->
		  Exec "tree", (err, stdout, sderr) ->
		    console.log "Scaffold ready!"
		    return

	if !Flags.scaffold

		# Do work on users global norma
		process.chdir Path.resolve __dirname, '../../'

		config = require Path.join process.cwd(), 'package.json'

		console.log config

		# Change back to project cwd for further tasks
		process.chdir cwd

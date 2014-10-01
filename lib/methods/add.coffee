Path = require "path"
Exec = require('child_process').exec
Flags = require('minimist')( process.argv.slice(2) )
Ghdownload = require("github-download")

# norma add --scaffold <git repo>
module.exports = (tasks, cwd) ->

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

Path = require "path"
Fs = require "fs-extra"
Exec = require('child_process').exec


###

	runConfigCommandCommand is a utility to run post build scripts
	that can be defined per project. I think this should be abstracted
	into another file since it is used in other places on the tool.

	@todo - abstract this function

###
module.exports = (action, cwd, cb) ->

	file = Fs.existsSync(
		Path.join(cwd, action)
	)

	if file
		require Path.join(cwd, action)

	else
		child = Exec(action, {cwd: cwd}, (err, stdout, stderr) ->

			throw err if err

			if typeof cb is "function"
				cb null
		)

		child.stdout.setEncoding("utf8")
		child.stdout.on "data", (data) ->
			str = data.toString()
			lines = str.split(/(\r?\n)/g)

			i = 0
			while i < lines.length
				if !lines[i].match "\n"
					message = lines[i].split("] ")

					if message.length > 1
						message.splice(0, 1)

					message = message.join(" ")

					console.log message
				i++

			return

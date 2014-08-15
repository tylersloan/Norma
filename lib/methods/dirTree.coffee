
fs = require 'fs'
path = require 'path'


dirTree = (filename) ->

	stats = fs.lstatSync(filename)

	info =
		path: filename
		name: path.basename(filename)

	if stats.isDirectory()
		info.type = "folder"
		info.children = fs.readdirSync(filename).map((child) ->
			dirTree filename + "/" + child
		)

	else
		# Assuming it's a file. In real life it could be a symlink or
		# something else!
		info.type = "file"

	info


module.exports = dirTree

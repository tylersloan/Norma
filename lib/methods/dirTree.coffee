
fs = require 'fs'
path = require 'path'


mkdir = (dir) ->

	# making directory without exception if exists
	try
		fs.mkdirSync dir
	catch e
		throw e	unless e.code is "EEXIST"
	return


copy = (src, dest, cb) ->
	oldFile = fs.createReadStream(src)
	newFile = fs.createWriteStream(dest)
	oldFile.pipe(newFile).on('close', (err) ->
		throw err if err

		if cb then cb dest
	)

	return


mapTree = (filename) ->

	stats = fs.lstatSync(filename)

	info =
		path: filename
		name: path.basename(filename)

	if stats.isDirectory()
		info.type = "folder"
		info.children = fs.readdirSync(filename).map((child) ->
			mapTree filename + "/" + child
		)

	else
		# Assuming it's a file. In real life it could be a symlink or
		# something else!
		info.type = "file"

	info

copyTree = (src, dest, cb) ->

	mkdir dest
	files = fs.readdirSync(src)
	i = 0

	while i < files.length
		current = fs.lstatSync(path.join(src, files[i]))
		if current.isDirectory()
			copyTree path.join(src, files[i]), path.join(dest, files[i])
		else if current.isSymbolicLink()
			symlink = fs.readlinkSync(path.join(src, files[i]))
			fs.symlinkSync symlink, path.join(dest, files[i])
		else
			copy(path.join(src, files[i]), path.join(dest, files[i]), (dest) ->
				console.log dest + 'has been moved over '
			)

		console.log i, files.length
		i++

	if cb then cb null
	return


removeTree = (dirPath, keep) ->
	try
		files = fs.readdirSync(dirPath)
	catch e
		return

	if files.length > 0
		i = 0

		while i < files.length

			filePath = dirPath + "/" + files[i]

			if fs.statSync(filePath).isFile()
				fs.unlinkSync filePath
			else
				removeTree filePath

			i++

	unless keep then fs.rmdirSync dirPath
	return

module.exports.mapTree = mapTree
module.exports.copyTree = copyTree
module.exports.copy = copy
module.exports.removeTree = removeTree

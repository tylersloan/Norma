
Path = require "path"
Multimatch = require "multimatch"
Findup = require "findup-sync"
ReadConfig = require "./read-config"

arrayify = (el) ->
	(if Array.isArray(el) then el else [el])


camelize = (str) ->
	str.replace /-(\w)/g, (m, p1) ->
		p1.toUpperCase()


module.exports = (tasks, cwd) ->

	finalObject = {}

	pattern = arrayify([
		"norma-*"
		"norma.*"
	])

	config = Findup "package.json", cwd: cwd

	node_modules = Findup "node_modules", cwd: cwd

	scope = arrayify([
		"dependencies"
		"devDependencies"
		"peerDependencies"
	])

	replaceString = /^norma(-|\.)/


	config = require(config)  if typeof config is "string"

	if !config
		throw new Error("Could not find dependencies. Do you have a package.json file in your project?")


	names = scope.reduce(
		(result, prop) ->
	  	result.concat Object.keys(config[prop] or {})
		[]
	)

	packageList = new Array
	packages = new Array

	Multimatch(names, pattern).forEach (name) ->

		# requireName = name.replace(replaceString, "")

		# requireName = camelize(requireName)
		packageList.push name

		return

	normaConfig = ReadConfig process.cwd()

	requireFn = (name) ->
		file = Path.resolve(node_modules, name)
		return require file

	mapPkge = (pkge) ->

		task = requireFn pkge

		taskObject = task normaConfig, Path.resolve(__dirname, '../../')
		taskObject = null

		packages.push task.tasks

	for pkge in packageList
		packageList[pkge] = mapPkge pkge


	return packages

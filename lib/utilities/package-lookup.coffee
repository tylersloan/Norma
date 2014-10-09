
Path = require "path"
Multimatch = require "multimatch"
Findup = require "findup-sync"

MapTree = require("./directory-tools").mapTree
ReadConfig = require "./read-config"

arrayify = (el) ->
	(if Array.isArray(el) then el else [el])


camelize = (str) ->
	str.replace /-(\w)/g, (m, p1) ->
		p1.toUpperCase()


requireFn = (cwd) ->

	return require cwd





module.exports = (tasks, cwd) ->

	normaConfig = ReadConfig process.cwd()
	packageList = new Array
	packages = new Array

	mapPkge = (pkgeCwd) ->

		task = requireFn pkgeCwd

		taskObject = task normaConfig, Path.resolve(__dirname, '../../')
		taskObject = null

		packages.push task.tasks



	if normaConfig.type is "package" or cwd.match /norma-packages/

		if cwd.match /norma-packages/
			cwd = Path.resolve cwd, "norma-packages"

		customs = MapTree cwd

		for pkge in customs.children

			if pkge.name and pkge.name.match /package[.](js|coffee)$/

				mapPkge pkge.path

	else

		pattern = arrayify([
			"#{Tool}-*"
			"#{Tool}.*"
		])

		config = Findup "package.json", cwd: cwd

		node_modules = Findup "node_modules", cwd: cwd

		scope = arrayify([
			"dependencies"
			"devDependencies"
			"peerDependencies"
		])

		replaceString = /^norma(-|\.)/



		if config
			# console.log(
			# 	Chalk.red("Could not find dependencies." +
			# 	" Do you have a package.json file in your project?"
			# 	)
			# )
			#
			config = require(config)

			names = scope.reduce(
				(result, prop) ->
			  	result.concat Object.keys(config[prop] or {})
				[]
			)

			Multimatch(names, pattern).forEach (name) ->

				packageList.push Path.resolve(node_modules, name)

				return

			for pkge in packageList
				packageList[pkge] = mapPkge pkge


	return packages

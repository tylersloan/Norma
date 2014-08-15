_				= require("lodash")
inquirer = require("inquirer")
fs			 = require("fs")
chalk		= require("chalk")
copyTree = require("../dirTree").copyTree
copy = require("../dirTree").copy
path = require("path")
build = require("./build")

module.exports = (project) ->

	for child in project.children
		if child.type is 'folder'
			copyTree(child.path, process.cwd())
		if child.type is 'file'
			copy(child.path, path.join(process.cwd(), child.name) )

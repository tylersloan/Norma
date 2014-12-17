Path = require "path"
Fs = require "fs-extra"

MapTree = require("./directory-tools").mapTree

module.exports = (tasks, cwd) ->

  node_modules = Path.join cwd, "node_modules"
  installed = MapTree node_modules, true
  
  console.log installed

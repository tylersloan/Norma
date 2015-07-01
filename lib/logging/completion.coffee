
Path = require "path"

MapTree = require("./../utilities/directory-tools").mapTree

module.exports = ->

  tasks = MapTree Path.resolve(__dirname, '../methods/')

  taskList = []
  for task in tasks.children
    if not task.path
      continue

    taskList.push task.name.split('.')[0]

  console.log taskList.join("\n").trim()

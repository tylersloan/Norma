###

  This file executes when a user says "norma create/init ...".  A new directory
  has been created for the new norma project and the process has already moved
  to that directory.  This script will gather info about the project from the
  user and then execute the scaffold script.

###
Fs = require "fs"
Path = require "path"
Inquirer = require "inquirer"
Q = require "kew"

Scaffold = require "./../utilities/scaffold"
MapTree = require("./../utilities/directory-tools").mapTree
RemoveTree = require("./../utilities/directory-tools").removeTree



module.exports = (tasks, cwd, answers) ->

  installed = Q.defer()

  if !tasks
    installed.reject("no name to in specified ")

  if !cwd then cwd = process.cwd()

  # cwd = path where norma package to be init'ed (same as process cwd)
  # tasks = [ 'create', <appName> ] - flags are not included in the array

  # Norma.userHome is this script files' directory
  scaffolds = MapTree Path.join Norma.userHome, "/scaffolds"

  # Add in custom option to list of scaffolds available
  scaffolds.children.push custom =
    path: cwd
    name: 'custom'
    type: 'folder'
    children: []

  # Create list of scaffold names for prompt
  scaffoldNames = (
    scaffold.name for scaffold in scaffolds.children when scaffold.children
  )


  # INSTAL --------------------------------------------------------------

  install = (answer) ->

    # Faster filter method
    projects = (
      p for p in scaffolds.children when p.name is answer.scaffold
    )

    # Use first match if one was found
    if !projects.length

      err =
        level: "warn"
        message:"That scaffold was not found.
          Try 'norma list --scaffold'"

      Norma.emit "error", err
      installed.reject(err)
      return


    if Fs.readdirSync(cwd).length
      installed.reject("not empty")
      return


    Scaffold(projects[0], answer.project, cwd)
      .then( ->
        installed.resolve("ok")
      )
      .fail( (err) ->
        installed.reject err
      )

    return




  # INIT ------------------------------------------------------------------

  doInit = (scaffoldNames, scaffolds) ->

    Inquirer.prompt([
      {
        type: "list"
        message: "What type of project do you want to build?"
        name: "scaffold"
        choices: scaffoldNames
      }
      {
        type: "input"
        message: "What do you want your project to be named?"
        name: "project"
        default: "My Awesome Project"
      }
      ],
      (answer) ->

        install answer
    )


  if !answers
    doInit scaffoldNames
  else
    install answers


  return installed

# API ----------------------------------------------------------------------

module.exports.api = [
  {
    command: ""
    description: "initalize a directory as a norma project"
  }
]

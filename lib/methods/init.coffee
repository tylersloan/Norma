_  = require("lodash")
Inquirer = require("inquirer")
Fs = require("fs-extra")
Chalk = require("chalk")
Path = require("path")

Scaffold = require("./../utilities/scaffold")
MapTree = require("./../utilities/directory-tools").mapTree
RemoveTree = require("./../utilities/directory-tools").removeTree

module.exports = (tasks, cwd) ->

  scaffolds = MapTree Path.join __dirname, "/../../scaffolds"

  # Add in custom option
  scaffolds.children.push custom =
    path: process.cwd()
    name: 'custom'
    type: 'folder'
    children: []

  # Create list of scaffold names for prompt
  scaffoldNames = new Array
  scaffoldNames = (scaffold.name for scaffold in scaffolds.children)

  # Generate list of current files in directory
  cwdFiles = _.remove Fs.readdirSync(cwd), (file) ->
    file.substring(0, 1) isnt "."


  chooseProject = (project, projectName) ->

    # Faster filter method
    projects = (proj for proj in scaffolds.children when proj.name is project)

    # If we found a project, build it
    if projects.length is 1
      Scaffold projects[0], projectName
    else
      console.log(
        Chalk.red 'That scaffold template is not found, try these:'
      )
      for name in scaffoldNames
        # Don't add an extra space after the last list
        if (_i + 1) isnt scaffoldNames.length
          console.log Chalk.cyan name
        else
          console.log Chalk.cyan name + '\n'


  startInit = ->

    if tasks.length is 1
      Inquirer.prompt([
        {
          type: "list"
          message: "What type of project do you want to build?"
          name: "projectType"
          choices: scaffoldNames
        }
        {
          type: "input"
          message: "What do you want your project to be named?"
          name: "projectName"
          default: "My Awesome Project"
        }
      ],
        (answer) ->
          chooseProject answer.projectType, answer.projectName
      )

    else
      Inquirer.prompt
        type: "input"
        message: "What do you want your project to be named?"
        name: "projectName"
        default: "My Awesome Project"
      ,
        (answer) ->

          chooseProject tasks[1], answer.projectName


  # Failsafe to make sure project is empty on creation of new folder
  if cwdFiles.length and tasks[0] isnt 'init'
    Inquirer.prompt
      type: "confirm"
      message: "Initializing will empty the current directory. Continue?"
      name: "override"
      default: false
    , (answer) ->

      if answer.override

        # Make really really sure that the user wants this
        Inquirer.prompt
          type: "confirm"
          message: "Removed files are gone forever. Continue?"
          name: "overridconfirm"
          default: false
        , (answer) ->

          if answer.overridconfirm

            # Clean up directory
            console.log Chalk.grey("Emptying current directory")
            RemoveTree cwd, true
            startInit()

          else
            process.exit 0

      else
        process.exit 0

  else if tasks.length is 1
    startInit()

  else
    chooseProject(tasks[1])


# API ----------------------------------------------------------------------

module.exports.api = [
  {
    command: ""
    description: "initalize a directory as a #{Tool} project"
  }
]

###

  Helper logging functions.
  This file contains basic information about the build tool
  It might be better off breaking it up into seperate logging functions
  Need to watch and see how the tool grows first
  ~ @jbaxleyiii

###

# require packages
Chalk = require 'chalk'
Path = require "path"

MapTree = require("./../utilities/directory-tools").mapTree


logTasks = ->

  console.log(
    Chalk.magenta('-v'),
    'or',
    Chalk.magenta('--version'),
    'to print out the version of your nsp CLI\n'
  )

  console.log('Please use one of the following tasks:')

  tasks = MapTree Path.resolve(__dirname, '../methods/')

  for task in tasks.children
    if task.path
      method = require(task.path).api

      if !method
        return

      oldName = ""
      name = task.name.split('.')[0]

      for api in method

        message = Chalk.magenta(name)

        commands = api.command.split(" ")
        for command in commands
          if command.match /--/
            message += " " + Chalk.gray command
          else
            message += " " + Chalk.green command


        if api.description
          message += "\n" + api.description

        console.log message


      # used for line breaks between command types
      if name isnt oldName

        console.log ""

      oldName = name





# PrettyPrint the NewSpring Church Logo -> https://newspring.cc
logInfo = (cliPackage) ->
  console.log(Chalk.green(
    '\n' +
    '\      .ttttttttttttttttt.    \n' +
    '\    :1111111111111111111111   \n' +
    '\  .111111111111111111111111i  \n' +
    '\ .1111111           .1111111;\n' +
    '\ t1111111     .1.     t11111t\n' +
    '\ 11111111     111     1111111\n' +
    '\ t1111111     111     1111111\n' +
    '\  1111111     111     1111111\n' +
    '\   t1111111111111111111111111\n' +
    '\     i11111111111111111111111\n',
    Chalk.grey('\nv' + cliPackage.version + '\nI just want to build websites\n' +
    '➳  //newspring.io\n' +
    '\n' +
    '-------')
  ))

  logTasks()


# Expose the logging functions
module.exports.logInfo = logInfo
module.exports.logTasks = logTasks

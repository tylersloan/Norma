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
    Chalk.white('-v'),
    'or',
    Chalk.white('--version'),
    "to print out the version of your norma CLI\n"
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

        message = Chalk.white(name)

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
  console.log(
    Chalk.magenta("
      \      8888888888888888888888888888888888888888888888888888888888888888\n
      \     8888888888888888888888888888888888888888888888888888888888888888\n
      \     8888887...................................................888888\n
      ======888888$7$77777777..............................77$$$$$777$888888======\n
      Z888888888888888888888888888O..................$8888888888888888888888888888\n
      \ Z888888888888888888888888888888$.........8888888888888888888888888888888\n
      \   O8888888888888OOOO888888888888O......Z888888888888888888888888888888\n
      \     88888888887..........O88888888....O888888887..........OO88888888\n
      \     8888888.................Z888888O.8888888.................Z8888888\n
      \    888888888888888888888888888888888888888888888888888888888888888888\n
      \   O8888888888888888888888888888888888888888888888888888888888888888888\n
      \   Z888888      888888888$     788888888888      888888888$     .888888\n
      \    O888888       88O88        8888888888888       88888        888888\n
      \    7888888Z                  88888888888888O                  8888888\n
      \     8888888888            888888888888888888888            888888888  \n
      \     8888888888888     8O88888888888888888888888888     8888888888888  \n
      \     8888888888888888888888888888888888888888888888888888888888888888  \n
      \     888888: O88888888888888Z   O8888888887..7888888888888888O.888888 \n
      \     888888:    ~8O88888.        O8888888........78O88888Z.....888888  \n
      \     888888=                       O888$.......................888888\n
      \     888888O                        88.........................888888\n
      \      888888                         ..........................888888\n
      \       888888O                       ..........................888888\n
      \       ~8888887                      ..........................888888\n
      \        8888888O                     ..........................888888\n
      \         88888888                    ..........................888888\n
      \           .88888888$                ..........................888888\n
      \             Z8888888888888888888888888888888888888888888888888888888\n
      \                   O8888888888888888888888888888888888888888888888888\n
      \                        .88888888888888888888888888888888888888888888\n
      \                       O88888888888         O88888888888\n
      \                      88888888888888       :8888888888888\n
  "
    )
  )

  logTasks()


# Expose the logging functions
module.exports.logInfo = logInfo
module.exports.logTasks = logTasks

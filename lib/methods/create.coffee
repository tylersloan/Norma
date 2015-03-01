###

  This file executes when a user says "norma create ...".  A new directory is
  created for the new norma project and the process moves to that directory
  before transfering execution to package.coffee or init.coffee depening on
  whether the --package flag was specified by the user.

###


Fs = require "fs"
Path = require "path"
Q = require "kew"

Norma = require "./../norma"
Init = require "./init"
Package = require "./../utilities/package"
MkDir = require("./../utilities/directory-tools").mkdir

module.exports = (tasks, cwd, pkge) ->

  if !cwd then cwd = process.cwd()

  installPackage = Norma.package


  if typeof pkge is "boolean"
    installPackage = pkge

  create = Q.defer()


  # cwd = absolute path of directory where user typed 'norma create <appName>'
  # tasks = [ <appName> ] - flags are not included in the array

  if !tasks or !tasks.length

    err =
      level: "crash"
      name: "Missing Info"
      message: "Please specify a project name"

    Norma.emit "error", err

    create.reject err
    return create


  packageName = tasks[0]

  # If this is a package it should look like "norma-#{name}"
  if installPackage and packageName.indexOf("norma-") isnt 0

    packageName = "norma-#{packageName}"

  # If packageName declared, create directory, else create in place
  MkDir Path.join(cwd, packageName)

  cwd = Path.join(cwd, packageName)

  # At this point we are in the project's directory root
  # process.chdir Path.join(cwd, packageName)

  # Make a package if we're supposed to

  if installPackage
    try
      Package tasks, cwd
    catch e
      create.reject e

    create.resolve("ok")
    return create

  # Otherwise init the norma project with a scaffold since its not a package


  Init(tasks, cwd, pkge)
    .then( ->
      create.resolve("ok")
    )
    .fail( (e) ->
      create.reject e
    )

  return create




# API ----------------------------------------------------------------------

module.exports.api = [
  {
    command: "<name>"
    description: "create a new scaffoled project from name"
  }
  {
    command: "<name> --package"
    description: "create a new package project from name"
  }
]

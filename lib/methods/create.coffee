###

  This file executes when a user says "norma create ...".  A new directory is
  created for the new norma project and the process moves to that directory
  before transfering execution to package.coffee or init.coffee depening on
  whether the --package flag was specified by the user.

###


Fs = require("fs-extra")
Chalk  = require("chalk")
Flags = require("minimist")( process.argv.slice(2) )
Init = require("./init")
Package = require "./../utilities/package"


module.exports = (tasks, cwd) ->

  # cwd = absolute path of directory where user typed 'norma create <appName>'
  # tasks = [ 'create', <appName> ] - flags are not included in the array

  if tasks.length < 2

    console.log Chalk.red "Please specify a project name"
    process.exit 0

  packageName = tasks[1]

  # If this is a package it should look like "norma-#{name}"
  if Flags.package and packageName.indexOf("#{Tool}-") isnt 0

    packageName = "#{Tool}-#{packageName}"

  # If packageName declared, create directory, else create in place
  try
    Fs.mkdirSync packageName, '0755'
  catch e
    throw e unless e.code is "EEXIST"

  # At this point we are in the project's directory root
  process.chdir packageName

  # Make a package if we're supposed to
  Package tasks, process.cwd() if Flags.package

  # Otherwise init the norma project with a scaffold since its not a package
  if not Flags.package

    Init tasks, process.cwd()

    if not Fs.existsSync('package.json')

      defaultPackageData =
        name: packageName

      Fs.writeFile 'package.json', JSON.stringify(defaultPackageData, null, 2)


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

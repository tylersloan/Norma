# To see an extended Error Stack Trace, uncomment
# Error.stackTraceLimit = 9000;

# Require the needed packages
Chalk = require "chalk"
Liftoff = require "Liftoff"
Argv = require("minimist")( process.argv.slice(2) )
Npm = require "npm"
Path = require "path"
Fs = require "fs-extra"
Semver = require "semver"
Inquirer = require "inquirer"

ExecCommand = require "./utilities/execute-command"
Run = require("./utilities/launcher").run


# UPDATE -----------------------------------------------------------------

# This should only run locally
if process.env.NODE_ENV isnt "production"

  # Run npm tasks within load per API found here:
  # https://docs.npmjs.com/api/load
  Npm.load( ->
    Npm.commands.view(["normajs", 'dist-tags.latest'], true, (err, data) ->
      if err
        Norma.events.emit "error", err

      try
        config = require Path.join __dirname, "../package.json"
      catch e

        Norma.events.emit "error", e
        return

      currentVersion = config.version
      availableVersion = currentVersion

      for key of data
        availableVersion = key
        break

      if !Semver.gte currentVersion, availableVersion

        message =
          level: "notify"
          message: "An update is available for Norma"
          color: "cyan"

        # use inquier method for updating Norma here

        Norma.events.emit "message", message

        Inquirer.prompt([
          {
            type: "list"
            message: "Would you like to update #{Tool}?"
            name: "update"
            choices: ["yes", "no"]
          }

          ],
          (answer) ->
            if answer.update is "yes"

              process.chdir Path.resolve __dirname, "../"

              ExecCommand(
                "npm update -g normajs"
                process.cwd()
                ,
                  ->
                    console.log(
                      Chalk.magenta "Norma updated!"
                    )

                    Run ["watch"]


              )
        )
    )
  )



# CLI configuration ---------------------------------------------------------

cli = new Liftoff({
  name: Tool
})
  .on("require", (name, module) ->

    # Handling of extenal modules via Liftoff's require method

    console.log Chalk.grey("Requiring external module: " + name + "...")

    if name is "coffee-script"
      module.register()

  )
  .on( "requireFail", (name, err) ->

    # Handle failures
    console.log Chalk.black.bgRed("Unable to load:", name, err)
  )


# Launch CLI -----------------------------------------------------------------

###

  Invoke acts as the main router file of the commands to be run

###
invoke = require("./utilities/launcher")

# Launch the CLI (Command Line Interface)
cli.launch(
  cwd: Argv.cwd
  configPath: Argv[Tool]
  require: Argv.require
  completion: Argv.completion
  verbose: Argv.verbose
  ,
    invoke
)

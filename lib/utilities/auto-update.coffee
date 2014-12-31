
Npm = require "npm"
Path = require "path"
Fs = require "fs-extra"
Semver = require "semver"
Inquirer = require "inquirer"

ExecCommand = require "./execute-command"

module.exports = ->

  # UPDATE ------------------------------------------------------------------

  # Run npm tasks within load per API found here:
  # https://docs.npmjs.com/api/load
  Npm.load( ->
    Npm.commands.view(["normajs", 'dist-tags.latest'], true, (err, data) ->
      if err
        Norma.events.emit "error", err

      try
        config = require Path.join __dirname, "../../package.json"
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

              ExecCommand(
                "npm update -g normajs"
                process.cwd()
                ,
                  ->
                    msg =
                      message: "Norma updated!"
                      color: "magenta"

                    Norma.emit "message", msg

                    Launcher.run ["watch"], process.cwd()


              )

            else
              if Norma.prompt._.initialized
                Norma.emit "message", "will ask again next update"


        )


    )
  )

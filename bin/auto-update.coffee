
Npm = require "npm"
Path = require "path"
Fs = require "fs"
Semver = require "semver"
Inquirer = require "inquirer"

ExecCommand = require "./../lib/utilities/execute-command"

module.exports = (preference) ->

  update = ->

    ExecCommand(
      "npm update -g normajs"
      process.cwd()
      ,
        ->
          msg =
            message: "Norma updated!"
            color: "cyan"

          Norma.log msg

          Norma.run()


    )


  # UPDATE ------------------------------------------------------------------

  # Run npm tasks within load per API found here:
  # https://docs.npmjs.com/api/load
  Npm.load( ->
    Npm.commands.view(["normajs", 'dist-tags.latest'], true, (err, data) ->
      if err
        Norma.emit "error", err

      try
        config = require Path.join __dirname, "../package.json"
      catch e

        Norma.emit "error", e
        return

      currentVersion = config.version
      availableVersion = currentVersion

      for key of data
        availableVersion = key
        break

      if !Semver.gte currentVersion, availableVersion

        skippedVersion = Norma.settings.get "version"

        if skippedVersion and Semver.gte skippedVersion, availableVersion
          # if Norma.prompt._.initialized
          #   Norma.prompt.pause()
          return

        Dont ask because user always wants latest and greatest
        if preference is "auto"
          update()
          return


        message =
          level: "notify"
          message: "An update is available for Norma"
          color: "cyan"

        # use inquier method for updating Norma here

        Norma.log message

        Inquirer.prompt([
          {
            type: "list"
            message: "Would you like to update norma?"
            name: "update"
            choices: ["yes", "no"]
          }

          ],
          (answer) ->
            if answer.update is "yes"

              update()

            else

              msg =
                message: "#{Norma.prefix}OK, I will ask again next update"
                color: "cyan"

              Norma.log msg


              # isolate settings to global scale
              Norma.settings._.remove "memory"
              Norma.settings._.remove "local"


              Norma.settings._.set "version", availableVersion
              # Save the configuration object to file
              Norma.settings._.save (err, data) ->
                throw err if err
        )


    )
  )

## v.NEXT (1.1)

* Added ability for packages to be extended in norma.json

  To extend a package, it must use the second argument passed on require
  and dynamically name its tasks from the name field. For example:

  ```coffeescript
  module.exports = (config, name) ->

    # set default task name
    if !name then name = "copy"

    # return if the package trying to be loaded isn't in norma.json
    if !config.tasks[name]
      return

    # dynamically set task
    Norma.task "#{name}", (cb) ->
      # do things in here
      cb null
      return


    Norma.tasks["#{name}"].order = order
    module.exports.tasks = Norma.tasks

  ```

  Now this package can be extended in a `norma.json` using the reserved @extend
  key. For example:

  ```javascript
  tasks: {
    "copy": {
      "src": "./raw",
      "dest": "./out"
    },
    "images": {
      "@extend": "copy"
      "src": "./second-raw",
      "dest": "./out"
    }
  }
  ```

* Added pass through to run packages with advanced methods. This allows running
 packages as Norma commands (e.g. `norma meteor reset`) and passing the args to
 the package for further use. A common use of this is when wrapping another
 CLI for use with Norma. You can pipe commands from Norma to the CLI using
 this method. For example:

 ```coffeescript

 Norma.task "meteor", (cb, tasks) ->

   # prepare is specific to norma-meteor (it handles package prep)
    prepare ->

      # if running via package commands, tasks will exists and be an
      # array of the remaining tasks (e.g. norma meteor reset -> ["reset"])
      if tasks

        # the Meteor.run tasks spawns meteor and passes tasks as the args
        Meteor.run tasks, ->

          # run callback to exit
          if typeof cb is "function"
            cb null

        return

 ```

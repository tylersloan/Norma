## 1.2

* First run of Norma test orchestration for local and CI
  environments. The test method revolves around the new
  test key used in a `norma.json`. There are a number
  of options available, a preview of what can be done is below.

  ```javascript
  // simple test method using norma package
  "test": "mocha"
  
  // will try to load a file and execute it
  "test": "./testingscripts/test.js"
  
  // will try to run shell script if package and file not found
  "test": "casper test"
  
  // will fall back to npm test if no test is found
  "test": "npm test" // implied
  
  // simple before, main, and after tasks
  "test": {
    // run a before script from package
    "before": "meteor run",
    // run a single task
    "main": "mocha",
    // run an after task
    "after": "meteor close"
  }
  
  // simple before, mutliple main, and simple after tasks
  "test": {
    // run a before script from package
    "before": "meteor run",
    // run an array of tasks in order
    "main": [
      "mocha", "casperjs --test", "karma"
    ],
    // run an after task
    "after": "meteor close"
  }
  
  // multi task testing with before and after actions
  "test": {
    // before can be a string or an array
    "before": [
      "docker start",
      // with no metoer tasks defined in tasks object,
      // this would run a shell command
      "cd out; meteor run --settings settings.json"
    ],
    // if extending existing task, this must have another name
    // this will inherit properties from packages defined in
    // tasks object
    "test-mocha": {
      "@extend": "mocha",
      "src": "./tests/mocha/**/*"
    },
    // if not extending (not defined in tasks), this can use
    // the package name
    "mocha-casperjs": {
      "src": "./tests/mocha-casperjs/**/*"
    },
     // after can be a string or an array
    "after": [
      // force kill running meteor tasks
      "kill -9 `ps ax | grep node | grep meteor | awk '{print $1}'`",
      "docker close"
    ]
  }
  
  // complex testing scenario with tasks dependents
  // multi action before, task loading tests, and
  // mutli action after
  "tasks": {
    "meteor": {
      "src": "out",
      "packages": [
        "meteor-platform",
        "iron:router"
      ],
      "platforms": [
        "server",
        "browser"
      ]
    }
  },
  "test": {
    "before": [
       "docker start",
      "./index.js",
      // use norma-meteor and pass run command
      "meteor run"
    ]
    "mocha": {
      "src": "./tests/mocha/**/*"
    }
    "after": [
      // stop active meteor from norma meteor
      "meteor close"
      "docker close"
    ]
  }

  ```

## 1.1

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

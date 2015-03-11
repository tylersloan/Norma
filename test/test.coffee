Chai    = require("chai").should()
Path    = require "path"
Fs      = require "fs"

Norma = require "./../lib/index"



describe "Test", ->

  fixtures = Path.resolve "./test/fixtures"
  Norma.silent = true
  oldCwd = process.cwd()
  oldConfig = Norma.config()

  # change into fixtures directory for testing
  before (done) ->

    process.chdir fixtures

    done()


  # /*
  #   new testing methods
  #
  # */
  #
  # // simple test method using norma package
  # "test": "mocha"
  #
  # // will try to load a file and execute it
  # "test": "./testingscripts/test.js"
  #
  # // will try to run shell script if package and file not found
  # "test": "casper test"
  #
  # // will fall back to npm test if no test is found
  # "test": "npm test" // implied
  #
  #
  #
  # // simple before, main, and after tasks
  # "test": {
  #   // run a before script from package
  #   "before": "meteor run",
  #   // run a single task
  #   "main": "mocha",
  #   // run an after task
  #   "after": "meteor close"
  # }
  #
  # // simple before, mutliple main, and simple after tasks
  # "test": {
  #   // run a before script from package
  #   "before": "meteor run",
  #   // run an array of tasks in order
  #   "main": [
  #     "mocha", "casperjs --test", "karma"
  #   ],
  #   // run an after task
  #   "after": "meteor close"
  # }
  #
  #
  # // multi task testing with before and after actions
  # "test": {
  #   // before can be a string or an array
  #   "before": [
  #     "docker start",
  #     // with no metoer tasks defined in tasks object,
  #     // this would run a shell command
  #     "cd out; meteor run --settings settings.json"
  #   ],
  #   // if extending existing task, this must have another name
  #   // this will inherit properties from packages defined in
  #   // tasks object
  #   "test-mocha": {
  #     "@extend": "mocha",
  #     "src": "./tests/mocha/**/*"
  #   },
  #   // if not extending (not defined in tasks), this can use
  #   // the package name
  #   "mocha-casperjs": {
  #     "src": "./tests/mocha-casperjs/**/*"
  #   },
  #   // after can be a string or an array
  #   "after": [
  #     // force kill running meteor tasks
  #     "kill -9 `ps ax | grep node | grep meteor | awk '{print $1}'`",
  #     "docker close"
  #   ]
  # }
  #
  #
  #
  # // complex testing scenario with tasks dependents
  # // multi action before, task loading tests, and
  # // mutli action after
  # "tasks": {
  #   "meteor": {
  #     "src": "out",
  #     "packages": [
  #       "meteor-platform",
  #       "iron:router"
  #     ],
  #     "platforms": [
  #       "server",
  #       "browser"
  #     ]
  #   }
  # },
  # "test": {
  #   "before": [
  #     "docker start",
  #     "./index.js",
  #     // use norma-meteor and pass run command
  #     "meteor run"
  #   ]
  #   "mocha": {
  #     "src": "./tests/mocha/**/*"
  #   }
  #   "after": [
  #     // stop active meteor from norma meteor
  #     "meteor close"
  #     "docker close"
  #   ]
  # }




  after (done) ->

    process.chdir oldCwd

    done()

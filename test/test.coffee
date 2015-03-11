Chai    = require("chai").should()
Path    = require "path"
Fs      = require "fs"
Rimraf  = require "rimraf"

Norma = require "./../lib/index"



describe "Test", ->

  fixtures = Path.resolve "./test/fixtures"
  Norma.silent = true
  oldCwd = process.cwd()
  oldConfig = Norma.config fixtures
  inFile = Path.join(fixtures, "images/test.html")
  outFile = Path.join(fixtures, "out/images/test.html")
  contents = 0

  saveFile = ->
    contents = Math.random()

    Fs.writeFileSync inFile, contents
    return


  readFile = ->
    return Fs.readFileSync(outFile, encoding: "utf8")



  # change into fixtures directory for testing
  beforeEach (done) ->

    # give time to download packages
    @.timeout 100000
    newConfig = Norma.config fixtures

    # set defaults for "mocha" task
    newConfig.tasks["mocha"] =
      "src": "images/**/*",
      "dest": "out/images"

    Norma.config.save newConfig, fixtures
    process.chdir fixtures

    Norma.getPackages(fixtures)
      .then( ->
        done()
      )


  ###

    For this testing suite, we are using a fork of norma-copy
    as the **testing** package. This way we can run file
    comparisons to make sure it executes correctly. It is being called
    norma-mocha for purposes of this test to relate to actual use

  ###
  # // simple test method using norma package
  # "test": "mocha"
  it "should allow a string to represent a package to be run", (done) ->

    _config = Norma.config()
    _config.test = "mocha"

    Norma.config.save _config, fixtures

    saveFile()

    Norma.test([])
      .then( (result) ->
        setTimeout ->
          readFile().should.equal contents.toString()
          done()
        , 100
      )
      .fail( (err) ->
        console.log err
      )


  # // will try to load a file and execute it
  # "test": "./testing-scripts/test.js"
  it "should allow a file to represent an action to be run", (done) ->

    _config = Norma.config()
    _config.test = "./testing-scripts/index.js"

    Norma.config.save _config, fixtures

    saveFile()

    Norma.test([])
      .then( (result) ->
        setTimeout ->
          readFile().should.equal contents.toString()
          done()
        , 100
      )
      .fail( (err) ->
        console.log err
      )



  # // will try to run shell script if package and file not found
  # "test": "casper test"
  it "should allow shell actions to be run", (done) ->

    _config = Norma.config()
    _config.test = "cp #{inFile} #{outFile}"

    Norma.config.save _config, fixtures


    saveFile()

    Norma.test([])
      .then( (result) ->
        setTimeout ->
          readFile().should.equal contents.toString()
          done()
        , 100
      )
      .fail( (err) ->
        console.log err
      )


  # // will fall back to npm test if no test is found
  # "test": "npm test" // implied
  it "should fall back to npm test if no test is found", (done) ->

    saveFile()

    Norma.test([])
      .then( (result) ->
        setTimeout ->
          readFile().should.equal contents.toString()
          done()
        , 100
      )
      .fail( (err) ->
        console.log err
      )


  # // can run a task in the `main` key of test
  # "test": {
  #   main: "casper test"
  # }
  it "should run a task in the `main` key of test", (done) ->

    _config = Norma.config()
    _config.test =
      main: "cp #{inFile} #{outFile}"

    Norma.config.save _config, fixtures


    saveFile()

    Norma.test([])
      .then( (result) ->
        setTimeout ->
          readFile().should.equal contents.toString()
          done()
        , 100
      )
      .fail( (err) ->
        console.log err
      )

  # // simple before, main, and after tasks
  # "test": {
  #   // run a before script from package
  #   "before": "meteor run",
  #   // run a single task
  #   "main": "mocha",
  #   // run an after task
  #   "after": "meteor close"
  # }
  it "should allow running simple before, main, and after tasks", (done) ->

    _config = Norma.config()
    _config.test =
      before: "mkdir ./complexTest"
      main: "./testing-scripts/index.js"
      after: "touch ./complexTest/index.js"


    Norma.config.save _config, fixtures

    saveFile()

    Norma.test([])
      .then( (result) ->
        setTimeout ->
          fileExists = Fs.existsSync("./complexTest/index.js")

          fileExists.should.be.true

          readFile().should.equal contents.toString()
          Rimraf.sync("./complexTest")
          done()
        , 100
      )
      .fail( (err) ->
        Rimraf.sync("./complexTest")
        done()
      )

    return

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
  it "should allow running simple before, mutliple main, and simple after tasks", (done) ->

    _config = Norma.config()
    _config.test =
      before: "mkdir ./complexTest"
      main: [
        "./testing-scripts/second-index.js"
        "./testing-scripts/index.js"
      ]
      after: "touch ./complexTest/index.js"


    Norma.config.save _config, fixtures

    saveFile()

    Norma.test([])
      .then( (result) ->
        setTimeout ->
          fileExists = Fs.existsSync("./complexTest/index.js")

          fileExists.should.be.true

          readFile().should.equal contents.toString()

          secondTest = Fs.readFileSync(
            "./out/images/second-test.html"
            encoding: "utf8"
          )

          secondTest.should.equal contents.toString()

          Rimraf.sync("./complexTest")
          done()
        , 100
      )
      .fail( (err) ->
        Rimraf.sync("./complexTest")
        done()
      )

  # // extending main tasks
  # "test": {
  #   // run an extended package
  #   "mocha test": {
  #     "@extend": "mocha"
  #   }
  # }
  it "should allow extending main tasks", (done) ->

    # CONIFG --------------------------------------------------------------
    _config = Norma.config()

    _config.test =
      "mocha test":
        "@extend": "mocha"


    Norma.config.save _config, fixtures

    # FILE SAVE -----------------------------------------------------------

    secondConents = Math.random()
    Fs.writeFileSync "./lib/test.js", secondConents
    saveFile()


    # TEST ----------------------------------------------------------------
    # force package lookup from config change
    Norma.getPackages(fixtures)
      .then( ->

        Norma.test([])
          .then( (result) ->
            setTimeout ->

              readFile().should.equal contents.toString()

              done()
            , 100
          )
          .fail( (err) ->
            done()
          )
      )

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




  afterEach (done) ->

    Norma.config.save oldConfig, fixtures

    process.chdir oldCwd

    done()

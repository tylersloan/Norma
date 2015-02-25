Chai    = require("chai").should()
Path    = require "path"
Fs      = require "fs"
Rimraf  = require "rimraf"

Norma = require "./../lib/index"


describe "Packages", ->

  fixtures = Path.resolve "./test/fixtures"
  fixturesJson = Path.resolve fixtures, "package.json"
  node_modules = Path.resolve fixtures, "node_modules"
  Norma.silent = true

  before (done) ->

    if Fs.existsSync(fixturesJson)
      Rimraf.sync fixturesJson

    defaultPackageData =
      name: "test-project"
      version: "0.0.0"
      description: ""
      main: "index.js"
      scripts:
        test: "echo \"Error: no test specified\" && exit 1"
      author: ""
      license: "MIT"


    Fs.writeFileSync fixturesJson, JSON.stringify(defaultPackageData, null, 2)

    if Fs.existsSync node_modules
      Rimraf.sync node_modules

    done()

  describe "install process", ->
    it "should have no installed modules", ->
      pkgeJson = Fs.readFileSync fixturesJson, encoding: "utf8"

      pkgeJson.should.not.contain.any.keys["dependencies"]


    it "should download needed packages", ->

      # set massive timeout incase npmjs or github are slow
      @.timeout 100000
      Norma.getPackages(fixtures)
        .then( (packages) ->

          pkgeJson = Fs.readFileSync fixturesJson, encoding: "utf8"

          packages.should
            .contain.any.keys["norma-copy"]
        )


    it "should have installed modules", ->
      pkgeJson = Fs.readFileSync fixturesJson, encoding: "utf8"

      pkgeJson.should.contain.any.keys["dependencies"]


    it "should be stored in Norma.packages", ->

      Norma.packages.should.include "norma-copy"


    it "should be stored in Norma.tasks", ->

      Norma.tasks.should.contain.any.keys "copy"


  describe "norma-copy", ->

    it "should have a fn key", ->

      Norma.tasks.copy.should.contain.any.keys "fn"

    it "should have a dep key", ->

      Norma.tasks.copy.should.contain.any.keys "dep"

    it "should have a name key", ->

      Norma.tasks.copy.should.contain.any.keys "name"

  describe "package running", ->

    it "should be promise based and return after scripts are run", (done) ->

      oldCwd = process.cwd()
      process.chdir fixtures
      alive = false
      Norma.build(["copy"], fixtures)
        .then( ->
            process.chdir oldCwd
            alive.should.be.true
            done()

        )
      alive = true

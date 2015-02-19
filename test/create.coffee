Chai    = require("chai").should()
Path    = require "path"
Fs      = require "fs"
Rimraf  = require "rimraf"

Norma = require("./../lib/norma")


describe "Create", ->

  norma_packages = Path.resolve "./test/fixtures/norma-packages"
  Norma.silent = true

  describe "package", ->

    pgkePath = Path.join(norma_packages, "norma-test")
    testProject = Path.resolve "./test/fixtures/"
    oldConfig = Norma.config testProject

    beforeEach (done) ->

      if !Fs.existsSync norma_packages
        Fs.mkdirSync norma_packages

      if Fs.existsSync pgkePath
        Rimraf.sync pgkePath

      return done()


    it "should require a name", ->

      Norma.create([], norma_packages, true).should.be.false


    it "should create a folder with norma- at the front", ->

      Norma.create(["test"], norma_packages, true)

      folderName = Path.basename pgkePath
      folderName = folderName.split("norma-")

      folderName[1].should.equal "test"


    it "should contain a norma.json", ->

      Norma.create(["test"], norma_packages, true)

      normaJson = Path.join pgkePath, "norma.json"

      exists = Fs.existsSync normaJson

      exists.should.be.true


    it "should contain a package.json", ->

      Norma.create(["test"], norma_packages, true)

      normaJson = Path.join pgkePath, "package.json"

      exists = Fs.existsSync normaJson

      exists.should.be.true


    it "should contain a package.coffee", ->

      Norma.create(["test"], norma_packages, true)

      normaJson = Path.join pgkePath, "package.coffee"

      exists = Fs.existsSync normaJson

      exists.should.be.true

    it "should create a working package", ->

      Norma.create(["test"], norma_packages, true)

      # hacky way to copy object
      config = (JSON.parse(JSON.stringify(oldConfig)))

      config.tasks["sample"] =
        src: "./test"
        dest: "./test/out"

      Norma.config.save(config, testProject)

      Norma.getPackages(testProject)
        .then( ->
          # console.log Norma
          Norma.tasks.should.contain.any.keys "sample"
        )


    afterEach (done) ->

      if Fs.existsSync pgkePath
        Rimraf.sync pgkePath

      return done()


    after (done) ->

      Norma.config.save(oldConfig, testProject)

      return done()

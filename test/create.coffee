Chai    = require("chai").should()
Path    = require "path"
Fs      = require "fs"
Rimraf  = require "rimraf"

Norma = require("./../lib/norma")


describe "Create", ->

  Norma.silent = true

  it "should return a promise", ->

    promise = Norma.create()
    promise._isPromise.should.be.true


  describe "package", ->

    norma_packages = Path.resolve "./test/fixtures/norma-packages"

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

      Norma.create([], norma_packages, true)
        .then( (resolve) ->

          resolve.should.equal "ok"

        )
        .fail( (err) ->

          err.should.exist
        )


    it "should create a folder with norma- at the front", ->

      Norma.create(["test"], norma_packages, true)
        .then( (resolve) ->

          folderName = Path.basename pgkePath
          folderName = folderName.split("norma-")

          folderName[1].should.equal "test"

        )




    it "should contain a norma.json", ->

      Norma.create(["test"], norma_packages, true)
        .then( (resolve) ->

          normaJson = Path.join pgkePath, "norma.json"

          exists = Fs.existsSync normaJson

          exists.should.be.true

        )


    it "should contain a package.json", ->

      Norma.create(["test"], norma_packages, true)
        .then( (resolve) ->

          normaJson = Path.join pgkePath, "package.json"

          exists = Fs.existsSync normaJson

          exists.should.be.true

        )



    it "should contain a package.coffee", ->

      Norma.create(["test"], norma_packages, true)
        .then( (resolve) ->

          normaJson = Path.join pgkePath, "package.coffee"

          exists = Fs.existsSync normaJson

          exists.should.be.true

        )



    it "should create a working package", ->

      Norma.create(["test"], norma_packages, true)
        .then( (resolve) ->

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

        )



    afterEach (done) ->

      if Fs.existsSync pgkePath
        Rimraf.sync pgkePath

      if Fs.existsSync norma_packages
        Rimraf.sync norma_packages

      return done()


    after (done) ->

      Norma.config.save(oldConfig, testProject)

      return done()


  # SCAFFOLDS ------------------------------------------------------------

  describe "scaffolds", ->

    tempProject = Path.resolve "./test/temp-fixtures/"
    testProject = Path.join tempProject, "test"
    answers =
      scaffold: "custom"
      project: "test"

    beforeEach (done) ->

      if !Fs.existsSync tempProject
        Fs.mkdirSync tempProject

      if Fs.existsSync testProject
        Rimraf.sync testProject

      return done()


    it "should require a name", ->

      Norma.create([], tempProject, answers)
        .then( (resolve) ->

          resolve.should.not.equal "ok"

        )
        .fail( (err) ->

          err.should.exist
        )


    it "should contain a norma.json", ->

      Norma.create(["test"], tempProject, answers)
        .then( (resolve) ->

          normaJson = Path.join tempProject, "test", "norma.json"

          exists = Fs.existsSync normaJson

          exists.should.be.true

        )
        .fail( (err) ->
          err.should.not.exist
        )


    it "should create a norma.json with the right name", ->

      Norma.create(["test"], tempProject, answers)
        .then( (resolve) ->

          normaJson = Path.join tempProject, "test", "norma.json"

          _config = Fs.readFileSync normaJson, encoding: "utf8"

          _config = JSON.parse _config
          _config.name.should.equal "test"

        )


    it "should contain a package.json", ->

      Norma.create(["test"], tempProject, answers)
        .then( (resolve) ->

          pkgeJSON = Path.join tempProject, "test", "package.json"
          exists = Fs.existsSync pkgeJSON

          exists.should.be.true

        )


    afterEach (done) ->

      if Fs.existsSync tempProject
        Rimraf.sync tempProject


      return done()

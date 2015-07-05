Chai    = require("chai").should()
Path    = require "path"
Fs      = require "fs"
Rimraf  = require "rimraf"

Norma = require "./../lib/index"

describe "Init", ->


  tempProject = Path.resolve "./test/temp-fixtures/"

  answers =
    scaffold: "custom"
    project: "second-test"


  beforeEach (done) ->

    if !Fs.existsSync tempProject
      Fs.mkdirSync tempProject

    return done()


  it "should require a name", ->

    Norma.init([], tempProject, answers)
      .then( (resolve) ->

        resolve.should.not.equal "ok"

      )
      .fail( (err) ->

        err.should.exist
      )


  it "should contain a Norma file", ->

    Norma.init(["test"], tempProject, answers)
      .then( (resolve) ->

        normaJson = Path.join tempProject, "Norma"

        exists = Fs.existsSync normaJson

        exists.should.be.true

      )
      .fail( (err) ->
        err.should.not.exist
      )


  it "should create a norma.json with the right name", ->

    Norma.init(["test"], tempProject, answers)
      .then( (resolve) ->

        _config = Norma.config(tempProject)

        _config.name.should.equal "second-test"

      )


  it "should contain a package.json", ->

    Norma.init(["test"], tempProject, answers)
      .then( (resolve) ->

        pkgeJSON = Path.join tempProject, "package.json"
        exists = Fs.existsSync pkgeJSON

        exists.should.be.true

      )


  afterEach (done) ->

    if Fs.existsSync tempProject
      Rimraf.sync tempProject


    return done()

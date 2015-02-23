Chai    = require("chai").should()
Path    = require "path"
Fs      = require "fs"

Norma = require "./../lib/index"



describe "Build", ->

  fixtures = Path.resolve "./test/fixtures"
  Norma.silent = true

  before (done) ->

    Norma.getPackages(fixtures)
      .then( ->
        return done()
      )


  it "should return a promise", ->

    status = Norma.build [], fixtures
    status._isPromise.should.be.true


  it "should allow a success function", ->

    Norma.build([], fixtures)
      .then( (result) ->
        result.should.be.equal "ok"
      )



  it "should allow a fail function", ->

    Norma.build([], process.cwd())
      .fail( (e) ->
        e.should.exist
      )



  it "should allow passing a task to be built", ->

    Norma.build(["copy"], fixtures)
      .then( (result) ->
        result.should.be.equal "ok"
      )
      .fail( (e) ->
        e.should.not.exist
      )

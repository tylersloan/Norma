Chai    = require("chai").should()
Path    = require "path"
Fs      = require "fs"

Norma = require "./../lib/index"



describe "Test", ->

  fixtures = Path.resolve "./test/fixtures"
  Norma.silent = true
  oldCwd = process.cwd()

  before (done) ->


    process.chdir fixtures

    Norma.getPackages(fixtures)
      .then( ->
        return done()
      )


  it "should return a promise", ->

    status = Norma.test ["build"], fixtures
    status._isPromise.should.be.true


  it "should allow a success function", ->

    Norma.test(["build"], fixtures)
      .then( (result) ->
        result.should.be.equal "ok"
      )



  it "should allow a fail function", ->

    Norma.test(["build"], oldCwd)
      .fail( (e) ->
        e.should.exist
      )



  # it "should allow passing a task to be built", ->
  #
  #   Norma.build(["copy"], fixtures)
  #     .then( (result) ->
  #       result.should.be.equal "ok"
  #     )
  #     .fail( (e) ->
  #       e.should.not.exist
  #     )
  after (done) ->

    process.chdir oldCwd

    done()

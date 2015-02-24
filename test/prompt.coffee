Chai    = require("chai").should()
Path    = require "path"
Fs      = require "fs"
Rimraf  = require "rimraf"
Spawn   = require("child_process").spawn

Norma   = require "./../lib/index"

describe "Prompt", ->

  fixtures = Path.resolve "./test/fixtures"
  fixturesJson = Path.resolve fixtures, "package.json"
  node_modules = Path.resolve fixtures, "node_modules"
  Norma.silent = true

  beforeEach (done) ->

    if Norma.prompt.open
      Norma.prompt.pause()

    return done()

  it "should require the prompt to be initalized prior to adding listeners", ->

    Norma.prompt.listen (err, result) ->

      err.should.equal "prompt not initiatied"


  it "should open a readline interface on function call", ->

    if !Norma.prompt.open

      Norma.prompt()

      Norma.prompt.open.should.be.true

    # fail the test
    else false.should.be.true


  it "should allow pausing of the interface", ->

    if !Norma.prompt.open

      Norma.prompt()

    Norma.prompt.open.should.be.true

    Norma.prompt.pause()

    Norma.prompt.open.should.be.false

  # describe "autocomplete", ->
  #
  #   it "should allow passing an array to autocomplete", ->

  # it "should allow typing commands and running functions", ->

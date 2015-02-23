Chai    = require("chai").should()
Path    = require "path"
Fs      = require "fs"
Rimraf  = require "rimraf"

Norma   = require "./../lib/index"

describe "Install", ->

  fixtures = Path.resolve "./test/fixtures"
  fixturesJson = Path.resolve fixtures, "package.json"
  node_modules = Path.resolve fixtures, "node_modules"
  Norma.silent = true


  it "should require a task", ->

    Norma.install([], (err, result) ->
      if err
        err.should.contain.any.keys ["message"]
    )

    # installed.should.be.undefined


  describe "Scaffolds", ->

    it "should download only repo with norma in the name", ->

      Norma.install(["NewSpring/foobar"], fixtures, true, (err) ->
        if err
          err.should.contain.any.keys ["message"]


      )


    # it "should download a package from github and install it", ->
    #
    #   Norma.install(
    #     ["NewSpring/norma-sample-scaffold"],
    #     fixtures,
    #     true,
    #     (err, result) ->
    #       console.log "why hello there"
    #       console.log err, result
    #       # if err
    #       #   err.should.be.undefined
    #       #
    #       # sample = Path.join(
    #       #   Norma._.userHome, "scaffolds", "sample-scaffold"
    #       # )
    #       #
    #       # Fs.existsSync(sample).should.be.true
    #
    #   )

    # it "should show up in listed scaffolds", ->
    #
    #   scaffolds = Norma.list([], fixtures, true)
    #
    #   scaffolds.should.include "sample-scaffold"

  # describe "Packages", ->
  #
  #   it "should"

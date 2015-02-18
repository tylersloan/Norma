Chai = require("chai").should()
Path = require "path"
Fs   = require "fs"

Norma = require("./../lib/norma")


describe "Packages", ->

  fixtures = Path.resolve "./test/fixtures"
  fixturesJson = Path.resolve fixtures, "package.json"

  it "should download needed packages", ->

    @.timeout 10000

    pkgeJson = Fs.readFileSync fixturesJson, encoding: "utf8"

    Norma.silent = true

    if !pkgeJson.dependencies

      Norma.getPackages(fixtures)
        .then( (packages) ->

            pkgeJson = Fs.readFileSync fixturesJson, encoding: "utf8"

            packages.should
              .contain.any.keys["norma-copy"]
        )


    # if !pkgeJson.dependencies["norma-copy"]

  # it "should load all existing packages", ->
  #
  #   Norma.ready([], process.cwd()).then ->
  #     pkges = Norma.getPackages()
  #     pkagesList = Norma.packages
  #     pkagesList.should.equal ["norma-copy"]

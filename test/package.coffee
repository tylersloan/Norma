Chai = require("chai").should()
Path = require "path"
Fs   = require "fs"

Norma = require("./../lib/norma")


describe "Packages", ->

  fixtures = Path.resolve "./test/fixtures"

  it "should download needed packages", ->
    pkgeJson = Fs.readFileSync "package.json", encoding: "utf8"

    if !pkgeJson.dependencies

      pkges = Norma.getPackages(fixtures)

      console.log pkges
        #
        # pkgeJson = Fs.readFileSync "package.json", encoding: "utf8"
        #
        # pkgeJson.dependencies["norma-copy"].should
        #   .contain.any.keys["norma-copy"]

    # if !pkgeJson.dependencies["norma-copy"]

  # it "should load all existing packages", ->
  #
  #   Norma.ready([], process.cwd()).then ->
  #     pkges = Norma.getPackages()
  #     pkagesList = Norma.packages
  #     pkagesList.should.equal ["norma-copy"]

Chai    = require("chai").should()
Path    = require "path"
Fs      = require "fs"
_ = require "underscore"


describe "Lists", ->

  fixtures = Path.resolve "./test/fixtures"

  describe "scaffold", ->

    it "should return an array of scaffolds if installed", ->

      scaffolds = Norma.list([], fixtures, true)

      scaffolds.should.be.an "array"


    it "should return all folders in Norma.userHome/scaffolds", ->

      scaffoldDir = Path.join Norma.userHome , "scaffolds"

      files = Fs.readdirSync scaffoldDir

      scaffolds = (
        child for child in files
      )

      _scaffolds = Norma.list([], fixtures, true)

      _scaffolds.should.eql scaffolds


  describe "packages", ->

    it "should list all found packages stored in Norma.packages", ->

      pkges = Norma.list([], fixtures)

      pkges.should.eql Norma.packages


    it "should return only unique packages", ->

      pkges = Norma.list([], fixtures)

      pkges.should.eql _.uniq(pkges)

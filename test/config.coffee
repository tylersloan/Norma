Chai    = require("chai").should()
Path    = require "path"
Fs      = require "fs"
Rimraf  = require "rimraf"

Norma = require("./../lib/norma")


describe "Config", ->

  fixtures = Path.resolve "./test/fixtures"
  config = Norma.config fixtures

  it "should return an object", ->

    Object.keys(config).length.should.be.above 1


  it "should have a tasks object", ->

    config.should.contain.any.keys ["tasks"]


  it "should match the norma.json", ->

    rawConfig = require(Path.join(fixtures, "norma.json"))

    config.should.be.deep.equal rawConfig


  it "should return false if no config found", ->

    Norma.config().should.be.false


  describe ".save()", ->

    currentConfig = {}

    before (done) ->

      currentConfig = Norma.config fixtures

      return done()


    it "should allow saving an object to the norma.json", ->

      newConfig =
        name: "test"
        tasks:
          javascript:
            src: "./lib"
            dest: "./out"

      Norma.config.save(newConfig, fixtures)

      _configPath = Path.join(fixtures, "norma.json")
      newConfigFile = JSON.parse Fs.readFileSync _configPath, encoding: "utf8"

      newConfig.should.be.deep.equal newConfigFile


    it "should require an object passed", ->

      Norma.config.save().should.be.false


    after (done) ->

      Norma.config.save currentConfig, fixtures

      return done()

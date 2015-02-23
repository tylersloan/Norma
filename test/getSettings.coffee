Chai = require("chai").should()
Path = require "path"
Fs = require "fs"
Rimraf = require "rimraf"

Norma = require "./../lib/index"

describe "getSettings", ->


  it "should be return an object", ->

    settings = Norma.getSettings()

    settings.should.be.an "object"

  it "should be contain a path key", ->

    settings = Norma.getSettings()

    settings.should.contain.any.keys "path"


  describe "get", ->

    it "should return a value if passed a key", ->

      path = Norma.getSettings.get "path"

      path.should.be.a "string"

    it "should return an object if passed nothing", ->

      path = Norma.getSettings.get()

      path.should.be.an "object"


  describe "set", ->

    it "should add to the object", ->

      originalSettings = Norma.getSettings()

      newSettings = Norma.getSettings.set("test", true)

      originalSettings.should.not.deep.equal newSettings


  describe "_", ->

    it "should be an object with multiple keys", ->

      _settings = Norma.getSettings._

      Object.keys(_settings).length.should.be.above 1


    it "should have at least two stores of data", ->

      _settings = Norma.getSettings._

      Object.keys(_settings.stores).length.should.be.above 1

    describe "stores", ->

      it "should be from a .norma file if type is `file`", ->

        _settings = Norma.getSettings._

        for store of _settings.stores

          if _settings.stores[store].type is "file"
            _settings.stores[store].file.should.contain ".norma"


      it "should be at Norma.userHome if global", ->

        _settings = Norma.getSettings._

        _settings.stores.global.file.should.contain Norma._.userHome


      it "should be at process.cwd() if local", ->

        _settings = Norma.getSettings._

        baseName = Path.basename process.cwd()

        _settings.stores.local.file.should.contain baseName

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

    Norma.install()
      .fail( (err) ->
        err.should.contain.any.keys ["message"]
      )



  describe "Scaffolds", ->

    it "should download only repo with norma in the name", ->

      Norma.install(["NewSpring/foobar"], fixtures, true)
        .fail( (err) ->

          err.should.contain.any.keys ["message"]

        )


    it "should download a package from github and install it", ->

      @.timeout 10000
      Norma.install(["NewSpring/norma-sample-scaffold"], fixtures, true)
        .then( (result) ->
            sample = Path.join(
              Norma._.userHome, "scaffolds", "sample-scaffold"
            )

            Fs.existsSync(sample).should.be.true

        )
        .fail( (err) ->

          err.should.be.undefined
        )

    it "should show up in listed scaffolds", ->

      scaffolds = Norma.list([], fixtures, true)

      scaffolds.should.include "sample-scaffold"


  describe "Packages", ->

    js = Path.join node_modules, "norma-meteor"
    globalJs = Path.join(
      Norma._.userHome, "node_modules", "norma-meteor"
    )

    beforeEach (done) ->

      @.timeout 10000
      if Fs.existsSync js
        Rimraf.sync js

      if Fs.existsSync globalJs
        Rimraf.sync globalJs

      json = JSON.parse(Fs.readFileSync fixturesJson, encoding: "utf8")

      delete json.devDependencies

      Fs.writeFileSync fixturesJson, JSON.stringify(json, null, 2)



      done()

    it "install npm package with norma- at front of the name", ->

      @.timeout 100000
      Norma.install(["meteor"], fixtures)
        .then( ->
          Fs.existsSync(js).should.be.true
        )

    it "install allow an object to be used for installation", ->

      @.timeout 100000

      obj =
        name: "meteor"

      Norma.install(obj, fixtures)
        .then( ->
          Fs.existsSync(js).should.be.true
        )


    it "install allow packages to be installed globally", ->

      @.timeout 100000

      obj =
        name: "meteor"
        global: true

      Norma.install(obj, fixtures)
        .then( ->
          Fs.existsSync(globalJs).should.be.true
        )

    it "install allow packages to be installed from a git repo", ->

      @.timeout 100000

      obj =
        name: "meteor"
        endpoint: "NewSpring/norma-meteor"

      Norma.install(obj, fixtures)
        .then( ->
          Fs.existsSync(js).should.be.true
        )

    it "install allow packages to be installed as a dev dependency", ->

      @.timeout 100000

      obj =
        name: "meteor"
        endpoint: "NewSpring/norma-meteor"
        dev: true

      Norma.install(obj, fixtures)
        .then( ->
          json = JSON.parse(Fs.readFileSync fixturesJson, encoding: "utf8")
          json.devDependencies.should.contain.any.keys "norma-meteor"
        )

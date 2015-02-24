Chai    = require("chai").should()
Path    = require "path"
Fs      = require "fs"
Rimraf  = require "rimraf"

Norma   = require "./../lib/index"

describe "Remove", ->

  fixtures = Path.resolve "./test/fixtures"
  fixturesJson = Path.resolve fixtures, "package.json"
  node_modules = Path.resolve fixtures, "node_modules"
  Norma.silent = true


  it "should require a task", ->

    Norma.remove()
      .fail( (err) ->
        err.should.contain.any.keys ["message"]
      )



  describe "Scaffolds", ->

    before (done) ->

      Norma.install(["NewSpring/norma-sample-scaffold"], fixtures, true)
        .then( (result) ->
          done()
        )



    it "should only remove an installed scaffold", ->

      Norma.remove(["foobar"], fixtures, true)
        .fail( (err) ->

          err.should.contain.any.keys ["message"]

        )


    it "should remove the installed scaffold", ->

      sample = Path.join(
        Norma._.userHome, "scaffolds", "sample-scaffold"
      )

      if Fs.existsSync(sample)

        Norma.remove(["sample-scaffold"], fixtures, true)
          .then( (result) ->

            result.should.equal "ok"

          )


  #   it "should show up in listed scaffolds", ->
  #
  #     scaffolds = Norma.list([], fixtures, true)
  #
  #     scaffolds.should.include "sample-scaffold"
  #
  #
  # describe "Packages", ->
  #
  #   js = Path.join node_modules, "norma-javascript"
  #   globalJs = Path.join(
  #     Norma._.userHome, "packages", "node_modules", "norma-javascript"
  #   )
  #
  #   beforeEach (done) ->
  #
  #     if Fs.existsSync js
  #       Rimraf.sync js
  #
  #     if Fs.existsSync globalJs
  #       Rimraf.sync globalJs
  #
  #     json = JSON.parse(Fs.readFileSync fixturesJson, encoding: "utf8")
  #
  #     delete json.devDependencies
  #
  #     Fs.writeFileSync fixturesJson, JSON.stringify(json, null, 2)
  #
  #
  #
  #     done()
  #
  #   it "install npm package with norma- at front of the name", ->
  #
  #     @.timeout 100000
  #     Norma.install(["javascript"], fixtures)
  #       .then( ->
  #         Fs.existsSync(js).should.be.true
  #       )
  #
  #   it "install allow an object to be used for installation", ->
  #
  #     @.timeout 100000
  #
  #     obj =
  #       name: "javascript"
  #
  #     Norma.install(obj, fixtures)
  #       .then( ->
  #         Fs.existsSync(js).should.be.true
  #       )
  #
  #
  #   it "install allow packages to be installed globally", ->
  #
  #     @.timeout 100000
  #
  #     obj =
  #       name: "javascript"
  #       global: true
  #
  #     Norma.install(obj, fixtures)
  #       .then( ->
  #         Fs.existsSync(globalJs).should.be.true
  #       )
  #
  #   it "install allow packages to be installed from a git repo", ->
  #
  #     @.timeout 100000
  #
  #     obj =
  #       name: "javascript"
  #       endpoint: "NewSpring/norma-javascript"
  #
  #     Norma.install(obj, fixtures)
  #       .then( ->
  #         Fs.existsSync(js).should.be.true
  #       )
  #
  #   it "install allow packages to be installed as a dev dependency", ->
  #
  #     @.timeout 100000
  #
  #     obj =
  #       name: "javascript"
  #       endpoint: "NewSpring/norma-javascript"
  #       dev: true
  #
  #     Norma.install(obj, fixtures)
  #       .then( ->
  #         json = JSON.parse(Fs.readFileSync fixturesJson, encoding: "utf8")
  #         json.devDependencies.should.contain.any.keys "norma-javascript"
  #       )

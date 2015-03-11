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

    beforeEach (done) ->
      @.timeout 5000
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


    it "should be removed from listed scaffolds", ->

      oldScaffolds = Norma.list([], fixtures, true)

      oldScaffolds.should.include "sample-scaffold"

      Norma.remove(["sample-scaffold"], fixtures, true)
        .then( (result) ->

          scaffolds = Norma.list([], fixtures, true)

          scaffolds.should.not.include "sample-scaffold"

        )




  describe "Packages", ->

    js = Path.join node_modules, "norma-meteor"
    globalJs = Path.join(
      Norma._.userHome, "packages", "node_modules", "norma-meteor"
    )



    it "remove npm package with norma- at front of the name", ->

      @.timeout 100000
      Norma.install(["meteor"], fixtures)
        .then( ->
          Fs.existsSync(js).should.be.true

          Norma.remove(["meteor"], fixtures)
            .then( ->
              Fs.existsSync(js).should.be.not.true
            )
        )

  #   it "install allow an object to be used for installation", ->
  #
  #     @.timeout 100000
  #
  #     obj =
  #       name: "meteor"
  #
  #     Norma.install(obj, fixtures)
  #       .then( ->
  #         Fs.existsSync(js).should.be.true
  #       )
  #
  #
    it "install allow packages to be removed globally", ->

      @.timeout 100000

      obj =
        name: "meteor"
        global: true

      Norma.install(obj, fixtures)
        .then( ->
          Fs.existsSync(globalJs).should.be.true

          # hacky shim for global support
          Norma.global = true
          Norma.remove(["meteor"], fixtures)
            .then( ->
              Fs.existsSync(globalJs).should.be.not.true
              Norma.global = false
            )

        )


  #   it "install allow packages to be installed from a git repo", ->
  #
  #     @.timeout 100000
  #
  #     obj =
  #       name: "meteor"
  #       endpoint: "NewSpring/norma-meteor"
  #
  #     Norma.install(obj, fixtures)
  #       .then( ->
  #         Fs.existsSync(js).should.be.true
  #       )
  #
    it "install allow packages to be removed as a dev dependency", ->

      @.timeout 100000

      obj =
        name: "meteor"
        dev: true

      Norma.install(obj, fixtures)
        .then( ->
          json = JSON.parse(Fs.readFileSync fixturesJson, encoding: "utf8")
          json.devDependencies.should.contain.any.keys "norma-meteor"

          Norma.dev = true
          Norma.remove(["meteor"], fixtures)
            .then( ->

              json = JSON.parse(Fs.readFileSync fixturesJson, encoding: "utf8")

              json.devDependencies
                .should.not.contain.any.keys "norma-meteor"

              Norma.dev = false
            )

        )

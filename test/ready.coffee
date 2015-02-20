Chai    = require("chai").should()
Path    = require "path"
Fs      = require "fs"
Rimraf  = require "rimraf"
Npm     = require "npm"


describe "Ready", ->

  fixtures = Path.resolve "./test/fixtures"
  fixturesJson = Path.resolve fixtures, "package.json"
  node_modules = Path.resolve fixtures, "node_modules"


  it "should return a promise", ->

    ready = Norma.ready()
    ready._isPromise.should.be.true


  it "should install npm files", ->

    @.timeout 100000

    kew = Path.join node_modules, "kew"

    if Fs.existsSync kew
      Rimraf kew

    packageJson = Fs.readFileSync fixturesJson, encoding: "utf8"
    packageJson = JSON.parse packageJson

    packageJson.dependencies["kew"] = "0.3.4"

    Fs.writeFileSync(
      fixturesJson
      JSON.stringify(packageJson, null, 2)
    )

    Norma.ready([], fixtures)
      .then( ->

        exist = Fs.existsSync kew

        delete packageJson.dependencies["kew"]

        Fs.writeFileSync(
          fixturesJson
          JSON.stringify(packageJson, null, 2)
        )


        exist.should.be.true
      )

  it "should update installed modules", ->

    packageJson = Fs.readFileSync fixturesJson, encoding: "utf8"
    packageJson = JSON.parse packageJson

    oldVersion = Path.join node_modules, "kew", "package.json"
    oldVersion = JSON.parse(Fs.readFileSync oldVersion, encoding: "utf8")
    oldVersion = oldVersion.version

    packageJson.dependencies["kew"] = "^0.5.0"

    Fs.writeFileSync(
      fixturesJson
      JSON.stringify(packageJson, null, 2)
    )

    Norma.ready([], fixtures)
      .then( ->

        newVersion = Path.join node_modules, "kew", "package.json"
        newVersion = JSON.parse(Fs.readFileSync newVersion, encoding: "utf8")
        newVersion = newVersion.version

        delete packageJson.dependencies["kew"]

        Fs.writeFileSync(
          fixturesJson
          JSON.stringify(packageJson, null, 2)
        )


        oldVersion.should.not.equal newVersion
      )

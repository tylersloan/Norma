Chai    = require("chai").should()
Path    = require "path"
Fs      = require "fs"
Spawn   = require("child_process").spawn

# Norma = require "./../lib/index"
autoUpdate = require "./../bin/auto-update"


describe "Auto update", ->

  packageJson = Path.resolve __dirname, "../", "package.json"
  pkge = {}
  existingVersion = ""

  fixtures = Path.resolve "./test/fixtures"
  oldCwd = process.cwd()


  before (done) ->

    process.chdir fixtures

    pkge = JSON.parse(Fs.readFileSync(packageJson, encoding: "utf8") )

    existingVersion = pkge.version
    pkge.version = "0.1.0"

    Fs.writeFileSync(packageJson, JSON.stringify(pkge), null, 2)

    done()


  it "should request updating norma if possible", (done) ->

    @.timeout 100000

    results = []
    errors = []

    _norma = Spawn("node", ["../../bin/norma.js"], {cwd: fixtures})

    _norma.stdout.setEncoding("utf8")

    _norma.stderr.on "data", (data) ->
      str = data.toString()
      lines = str.split(/(\r?\n)/g)

      i = 0
      while i < lines.length
        if !lines[i].match "\n"
          message = lines[i].split("] ")

          if message.length > 1
            message.splice(0, 1)

          errors.push message.join(" ")

          # Norma.emit "message", message
        i++

      return


    _norma.stdout.on "data", (data) ->
      str = data.toString()
      lines = str.split(/(\r?\n)/g)

      i = 0
      while i < lines.length
        if !lines[i].match "\n"
          message = lines[i].split("] ")

          if message.length > 1
            message.splice(0, 1)

          results.push message.join(" ")

          # Norma.emit "message", message
        i++

      return

    _norma.on "close", ->
      console.log results, errors
      results.should.include "An update is available for Norma"
      done()
      # data.should.be.true

    setTimeout ->
      _norma.kill()
    , 10000


  after (done) ->

    pkge = JSON.parse(Fs.readFileSync packageJson, encoding: "utf8")

    pkge.version = existingVersion

    Fs.writeFileSync(packageJson, JSON.stringify(pkge, null, 2) )

    done()

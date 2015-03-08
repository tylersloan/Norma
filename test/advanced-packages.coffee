Chai    = require("chai").should()
Path    = require "path"
Fs      = require "fs"
Spawn   = require("child_process").spawn

Norma = require "./../lib/index"

describe "Advanced Package", ->

  fixtures = Path.resolve "./test/fixtures"
  oldCwd = process.cwd()
  oldConfig = Norma.config(fixtures)

  before (done) ->

    process.chdir fixtures

    newConfig = Norma.config fixtures

    newConfig.tasks["advanced"] =
      "src": "images/**/*",
      "dest": "out/images"

    Norma.config.save newConfig, fixtures

    done()

    return

  it "should pass arguments to main package task", ->

    @.timeout 100000

    results = []
    errors = []

    _norma = Spawn(
      "node", [
        "../../bin/norma.js", "advanced", "printed", "out"
      ],
      {
        cwd: fixtures
      }
    )

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
      if errors.length
        console.log errors

      console.log results

      results.should.include "printed out"
      done()
      # data.should.be.true

    setTimeout ->
      _norma.kill()
    , 10000


  after (done) ->

    Norma.config.save(oldConfig, fixtures)

    process.chdir oldCwd

    done()

    return

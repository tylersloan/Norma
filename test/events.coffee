Chai    = require("chai").should()
Path    = require "path"
Fs      = require "fs"

Norma = require("./../lib/norma")

describe "Events", ->

  describe "Emit", ->

    it "should accept a string as an event trigger", ->

      console.log Norma

      # Norma.emit "test-event"

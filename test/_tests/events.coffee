Chai    = require("chai").should()
Path    = require "path"
Fs      = require "fs"

Norma = require "./../lib/index"

describe "Events", ->

  describe "Subscribe", ->

    it "should register a new event", ->

      oldEvents = Norma._events
      oldCount = Object.keys(oldEvents)

      Norma.subscribe "test-event", ->

        return true

      newEvents = Norma._events
      newCount = Object.keys(newEvents)

      oldEvents.should.be.below newCount

    it "should register the string passed as the event key", ->

      string = "test-event"

      Norma._events.should.contain.any.keys "test-event"

    it "should require a callback as the second parameter", ->

      try
        Norma.subscribe "test-event"
      catch e
        true.should.be.true

  describe "Emit", ->

    it "should execute a function on emit", ->

      response = "hello world"

      Norma.subscribe "second-test", ->

        response.should.be.equal "hello world"

        return

      Norma.emit "second-test"


    it "should pass a variable to function on emit", ->

      shout = "hello world"

      Norma.subscribe "second-test", (answer) ->

        answer.should.be.equal "hello world"

        return

      Norma.emit "second-test", shout

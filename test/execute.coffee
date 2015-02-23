Chai    = require("chai").should()
Path    = require "path"
Fs      = require "fs"

Norma = require "./../lib/index"
SimpleTask = require("./methods/simpleTask")


# Taken from run-sequence
# https://github.com/OverZealous/run-sequence/blob/master/test/main.js
describe "Execute", ->

  task1 = SimpleTask()
  task2 = SimpleTask()
  task3 = SimpleTask()
  task4 = SimpleTask()

  Norma.task 'task1', task1
  Norma.task 'task2', task2
  Norma.task 'task3', task3
  Norma.task 'task4', [ 'task3' ], task4

  beforeEach (done) ->
    SimpleTask.resetRunCounter()
    task1.reset()
    task2.reset()
    task3.reset()
    task4.reset()
    return done()

  it 'should run a single task', ->
    Norma.execute 'task1'
    task1.counter.should.eql 1


  it 'should run multiple tasks', ->
    Norma.execute 'task1', 'task2'
    task1.counter.should.eql 1
    task2.counter.should.eql 2

  it 'should run simultaneous tasks', ->
    Norma.execute [
      'task1'
      'task2'
    ], 'task3'

    task1.counter.should.not.eql -1
    task2.counter.should.not.eql -1
    task3.counter.should.eql 3


  it 'should run task dependencies', ->
    Norma.execute 'task4'
    task1.counter.should.eql -1
    task2.counter.should.eql -1
    task3.counter.should.eql 1
    task4.counter.should.eql 2


  it 'should run task dependencies after previous tasks', ->
    Norma.execute 'task1', 'task4'
    task1.counter.should.eql 1
    task2.counter.should.eql -1
    task3.counter.should.eql 2
    task4.counter.should.eql 3


  it 'should handle the callback', ->
    wasCalled = false

    Norma.execute 'task1', 'task4', (err) ->
      if !err
        wasCalled = true


    task1.counter.should.eql 1
    task2.counter.should.eql -1
    task3.counter.should.eql 2
    task4.counter.should.eql 3

    wasCalled.should.be.true

  describe 'Input Array Handling', ->

    it 'should not modify passed-in parallel task arrays', ->
      taskArray = [
        'task1'
        'task2'
      ]
      Norma.execute taskArray
      taskArray.should.eql [
        'task1'
        'task2'
      ]

  describe 'Asynchronous Tasks', ->

    it 'should run a single task', ->

      task1.shouldPause = true
      Norma.execute 'task1'
      task1.counter.should.eql -1
      task1.continue()
      task1.counter.should.eql 1


    it 'should run multiple tasks', ->

      task1.shouldPause = true
      task2.shouldPause = true

      Norma.execute 'task1', 'task2'

      task1.counter.should.eql -1
      task2.counter.should.eql -1

      task1.continue()

      task1.counter.should.eql 1
      task2.counter.should.eql -1

      task2.continue()

      task2.counter.should.eql 2

    it 'should run simultaneous tasks', ->
      task1.shouldPause = true
      Norma.execute [
        'task1'
        'task2'
      ], 'task3'

      task1.counter.should.eql -1
      task2.counter.should.eql 1
      task3.counter.should.eql -1

      task1.continue()

      task1.counter.should.eql 2
      task3.counter.should.eql 3

    it 'should run task dependencies', ->
      task3.shouldPause = true

      Norma.execute 'task4'

      task3.counter.should.eql -1
      task4.counter.should.eql -1

      task3.continue()

      task3.counter.should.eql 1
      task4.counter.should.eql 2

    it 'should run task dependencies after previous tasks', ->

      task1.shouldPause = true
      task3.shouldPause = true
      task4.shouldPause = true

      Norma.execute 'task1', 'task4'

      task1.counter.should.eql -1
      task2.counter.should.eql -1
      task3.counter.should.eql -1
      task4.counter.should.eql -1

      task1.continue()

      task1.counter.should.eql 1
      task3.counter.should.eql -1
      task4.counter.should.eql -1

      task3.continue()

      task3.counter.should.eql 2
      task4.counter.should.eql -1

      task4.continue()

      task4.counter.should.eql 3

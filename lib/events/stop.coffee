
module.exports = ->

    Norma.events.on "stop", ->
      Norma.stop()

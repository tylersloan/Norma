module.exports = (tasks, cwd) ->
  console.log 'emmitting'
  Norma.emitter.emit 'start'

module.exports.api = [
  {
    command: "<process-name>"
    description: "start single process"
  }
  {
    command: "<process-name> <process-name> <process-name>"
    description: "start multiple processes"
  }
]

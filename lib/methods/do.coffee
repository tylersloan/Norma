###

  This method allows custom event emitting and is primarily designed for
  processed.

###


module.exports = (tasks, cwd) ->

  # This is the "do" in "norma do start"
  doTasks = tasks.shift()

  # If there is nothing specified (just "norma do"), emit doAll
  Norma.emitter.emit "doAll" if not tasks.length

  # Otherwise, emit all of the other things (like "norma do start jump"
  # would emit start and jump)
  while tasks.length

    nextTask = tasks.shift()
    Norma.emitter.emit nextTask


module.exports.api = [
  {
    command: ""
    description: "start all processes"
  }
  {
    command: "<process-name>"
    description: "start single process"
  }
  {
    command: "<process-name> <process-name> <process-name>"
    description: "start multiple processes"
  }
]

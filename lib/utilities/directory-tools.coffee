
Fs = require 'fs'
Path = require 'path'


# Set up a basic whitelist
whitelist = [
  '.git'
  'node_modules'
  '#{Tool}_packages'
  '.DS_Store'
]

mkdir = (dir) ->

  # making directory without exception if exists
  try
    Fs.mkdirSync dir, '0755'
  catch e
    throw e  unless e.code is "EEXIST"

  return


copy = (src, dest, cb) ->

  oldFile = Fs.createReadStream(src)
  newFile = Fs.createWriteStream(dest)

  oldFile
    .pipe(newFile)
    .on('close', (err) ->
      throw err if err

      if cb then cb dest
    )

  return


mapTree = (filename, ignore, force) ->

  mkdir filename

  if typeof ignore is "boolean"
    force = ignore
    ignore = ""

  if ignore and ignore.length
    for ignored in ignore
      if whitelist.indexOf(ignored) is -1
        whitelist.push ignored

  if whitelist.indexOf(Path.basename(filename)) is -1 or force
    stats = Fs.lstatSync filename

    info =
      path: filename
      name: Path.basename filename

    if stats.isDirectory()
      info.type = "folder"

      files = Fs.readdirSync filename

      info.children = (
        mapTree(filename + "/" + child, ignore) for child in files
      )


    else
      # Assuming it's a file. In real life it could be a symlink or
      # something else!
      info.type = "file"

    info

  else return false


copyTree = (src, dest, cb) ->

  mkdir dest
  files = Fs.readdirSync(src)
  i = 0

  while i < files.length

    current = Fs.lstatSync Path.join(src, files[i])

    if current.isDirectory()

      copyTree(
        Path.join(
          src
          files[i]
        )
        Path.join(
          dest
          files[i]
        )
      )

    else if current.isSymbolicLink()

      symlink = Fs.readlinkSync Path.join(src, files[i])

      Fs.symlinkSync symlink, Path.join(dest, files[i])
    else
      copy(Path.join(src, files[i]), Path.join(dest, files[i]))


    i++

  if cb then cb null

  return


removeTree = (dirPath, keep) ->

  try
    files = Fs.readdirSync(dirPath)
  catch e
    return

  if files.length > 0
    i = 0

    while i < files.length

      filePath = dirPath + "/" + files[i]

      if Fs.statSync(filePath).isFile()
        Fs.unlinkSync filePath
      else
        removeTree filePath

      i++

  unless keep then Fs.rmdirSync dirPath
  return


BUF_LENGTH = 64 * 1024

_buff = new Buffer(BUF_LENGTH)

# taken from fs-extra
copySync = (srcFile, destFile) ->
  fdr = Fs.openSync(srcFile, "r")
  stat = Fs.fstatSync(fdr)
  fdw = Fs.openSync(destFile, "w", stat.mode)
  bytesRead = 1
  pos = 0
  while bytesRead > 0
    bytesRead = Fs.readSync(fdr, _buff, 0, BUF_LENGTH, pos)
    Fs.writeSync fdw, _buff, 0, bytesRead
    pos += bytesRead
  Fs.closeSync fdr
  Fs.closeSync fdw


module.exports.mapTree = mapTree
module.exports.copyTree = copyTree
module.exports.copy = copy
module.exports.copySync = copySync
module.exports.removeTree = removeTree

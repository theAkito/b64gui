import
  base64,
  nigui,
  sequtils,
  os

proc encodeFilesToText(filePaths: seq[string]): seq[string] =
  result = filePaths.mapIt(it.lastPathPart & " " & it.readFile.encode)

proc encodeFilesToFiles(filePaths: seq[string]) =
  discard filePaths.map(
    proc (x: string): string =
      let s = x.readFile.encode
      (x.parentDir / "b64_" & x.lastPathPart).writeFile(s)
  )

when isMainModule:
  echo "Greetings!"

import
  base64,
  nigui,
  sequtils,
  os

proc encodeFilesToText(filePaths: seq[string]): seq[string] =
  result = filePaths.mapIt(it.lastPathPart & " " & it.readFile.encode)

proc encodeFilesToFiles(sourceFilePaths: seq[string], targetPath: string) =
  sourceFilePaths.apply(
    proc (x: string) =
      let s = x.readFile.encode
      (targetPath / "b64_" & x.lastPathPart).writeFile(s)
  )

when isMainModule:
  app.init
  var
    fileNames: seq[string]
    filePaths: seq[string]
    window = newWindow("Base64 GUI")
    container = newLayoutContainer(Layout_Vertical)
    button_selectFiles = newButton("Select Files...")
    button_selectDirectory = newButton("Select Directory...")
    textArea = newTextArea()
  window.width = 600.scaleToDpi
  window.height = 400.scaleToDpi
  window.add(container)
  container.add(button_selectFiles)
  container.add(button_selectDirectory)
  container.add(textArea)
  button_selectFiles.onClick = proc(event: ClickEvent) =
    var dialog = newOpenFileDialog()
    dialog.title = "Select files that are to be encoded."
    dialog.multiple = true
    # dialog.startDirectory = ""
    dialog.run()
    if dialog.files == @[]:
      textArea.addLine("No files selected.")
    else:
      dialog.files.apply(
        proc (x: string) =
          let fileName = x.lastPathPart
          filePaths.add(x)
          fileNames.add(fileName)
          textArea.addLine(fileName)
      )
      let saveFilesDialog = SelectDirectoryDialog(
        title: "Save Files to..."
      )
      saveFilesDialog.run
      if saveFilesDialog.selectedDirectory == "":
        textArea.addLine("No directory selected.")
      else:
        let targetDir = saveFilesDialog.selectedDirectory
        filePaths.encodeFilesToFiles(targetDir)
  button_selectDirectory.onClick = proc(event: ClickEvent) =
    var dialog = SelectDirectoryDialog()
    dialog.title = "Select directory containing files that are to be encoded."
    # dialog.startDirectory = ""
    dialog.run()
    if dialog.selectedDirectory == "":
      textArea.addLine("No directory selected.")
    else:
      textArea.addLine(dialog.selectedDirectory)
  window.show()
  app.run()

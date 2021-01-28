import
  base64,
  nigui,
  sequtils,
  os

proc longLineBreak(): string = "\p\p\p"
proc shortLineBreak(): string = "\p\p"

proc encodeFilesToText(filePaths: seq[string]): seq[string] =
  result = filePaths.mapIt(it.lastPathPart & shortLineBreak() & it.readFile.encode)

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
    button_selectFilesToText = newButton("Select Files and Print as Text")
    button_selectFilesToFiles = newButton("Select Files and Save as Files")
    button_selectDirectoryToText = newButton("Select Directory and Print Files as Text")
    button_selectDirectoryToFiles = newButton("Select Directory and Save Files as Files")
    button_clearTextArea = newButton("Clear Text Area")
    textArea = newTextArea()
  textArea.editable = false
  textArea.wrap = false
  window.width = 600.scaleToDpi
  window.height = 400.scaleToDpi
  window.add(container)
  container.add(button_selectFilesToText)
  container.add(button_selectFilesToFiles)
  container.add(button_selectDirectoryToText)
  container.add(button_selectDirectoryToFiles)
  container.add(button_clearTextArea)
  container.add(textArea)
  button_clearTextArea.onClick = proc(event: ClickEvent) =
    textArea.text=""
  button_selectFilesToFiles.onClick = proc(event: ClickEvent) =
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
        filePaths = @[]
        fileNames = @[]
  button_selectFilesToText.onClick = proc(event: ClickEvent) =
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
      )
      filePaths.encodeFilesToText.apply(
        proc (x: string) =
          textArea.addLine(x)
          textArea.addLine(longLineBreak())
      )
      filePaths = @[]
      fileNames = @[]
  button_selectDirectoryToText.onClick = proc(event: ClickEvent) =
    var dialog = SelectDirectoryDialog()
    dialog.title = "Select directory containing files that are to be encoded."
    # dialog.startDirectory = ""
    dialog.run()
    if dialog.selectedDirectory == "":
      textArea.addLine("No directory selected.")
    else:
      for kind, file in dialog.selectedDirectory.walkDir:
        if kind != pcFile: continue
        filePaths.add(file)
        fileNames.add(file.lastPathPart)
      filePaths.encodeFilesToText.apply(
        proc (x: string) =
          textArea.addLine(x)
          textArea.addLine(longLineBreak())
      )
      filePaths = @[]
      fileNames = @[]
  button_selectDirectoryToFiles.onClick = proc(event: ClickEvent) =
    var dialog = SelectDirectoryDialog()
    dialog.title = "Select directory containing files that are to be encoded."
    # dialog.startDirectory = ""
    dialog.run()
    if dialog.selectedDirectory == "":
      textArea.addLine("No directory selected.")
    else:
      for kind, file in dialog.selectedDirectory.walkDir:
        if kind != pcFile: continue
        filePaths.add(file)
        fileNames.add(file.lastPathPart)
      let saveFilesDialog = SelectDirectoryDialog(
        title: "Save Files to..."
      )
      saveFilesDialog.run
      if saveFilesDialog.selectedDirectory == "":
        textArea.addLine("No directory selected.")
      else:
        let targetDir = saveFilesDialog.selectedDirectory
        filePaths.encodeFilesToFiles(targetDir)
        filePaths = @[]
        fileNames = @[]
  window.show()
  app.run()

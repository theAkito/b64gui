import
  base64,
  nigui,
  sequtils,
  os

proc longLineBreak(): string = "\p\p\p"
proc shortLineBreak(): string = "\p\p"

proc encodeFilesToText(filePaths: seq[string]): seq[string] =
  filePaths.mapIt(it.lastPathPart & shortLineBreak() & it.readFile.encode)

proc encodeFilesToFiles(sourceFilePaths: seq[string], targetPath: string) =
  sourceFilePaths.apply(
    proc (x: string) =
      (targetPath / "b64_" & x.lastPathPart).writeFile(x.readFile.encode)
  )

template resetFileCollections() =
  filePaths = @[]
  fileNames = @[]

template saveOutputFiles() =
  let saveFilesDialog = SelectDirectoryDialog(
    title: "Save Files to..."
  )
  saveFilesDialog.run
  if saveFilesDialog.selectedDirectory == "":
    textArea.addLine("No directory selected.")
  else:
    let targetDir = saveFilesDialog.selectedDirectory
    filePaths.encodeFilesToFiles(targetDir)
    resetFileCollections

template printFilesToText() =
  filePaths.encodeFilesToText.apply(
    proc (x: string) =
      textArea.addLine(x)
      textArea.addLine(longLineBreak())
  )
  resetFileCollections

template getFilesFromDir() =
  for kind, file in dialog.selectedDirectory.walkDir:
    if kind != pcFile: continue
    filePaths.add(file)
    fileNames.add(file.lastPathPart)

template getSelectedFiles(printFilesToTextArea: bool): untyped =
  dialog.files.apply(
    proc (x: string) =
      let fileName = x.lastPathPart
      filePaths.add(x)
      fileNames.add(fileName)
      if printFilesToTextArea:
        textArea.addLine(fileName)
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
  let
    controllers: seq[ControlImpl] = @[
      button_selectFilesToText,
      button_selectFilesToFiles,
      button_selectDirectoryToText,
      button_selectDirectoryToFiles,
      button_clearTextArea,
      textArea
    ]
  textArea.editable = false
  textArea.wrap = false
  window.width = 600.scaleToDpi
  window.height = 400.scaleToDpi
  window.add(container)
  controllers.apply(proc(x: ControlImpl) = container.add(x))
  button_clearTextArea.onClick = proc(event: ClickEvent) = textArea.text = ""
  button_selectFilesToFiles.onClick = proc(event: ClickEvent) =
    var dialog = newOpenFileDialog()
    dialog.title = "Select files that are to be encoded."
    dialog.multiple = true
    dialog.run()
    if dialog.files == @[]:
      textArea.addLine("No files selected.")
    else:
      getSelectedFiles(true)
      saveOutputFiles
  button_selectFilesToText.onClick = proc(event: ClickEvent) =
    var dialog = newOpenFileDialog()
    dialog.title = "Select files that are to be encoded."
    dialog.multiple = true
    dialog.run()
    if dialog.files == @[]:
      textArea.addLine("No files selected.")
    else:
      getSelectedFiles(false)
      printFilesToText
  button_selectDirectoryToText.onClick = proc(event: ClickEvent) =
    var dialog = SelectDirectoryDialog()
    dialog.title = "Select directory containing files that are to be encoded."
    dialog.run()
    if dialog.selectedDirectory == "":
      textArea.addLine("No directory selected.")
    else:
      getFilesFromDir
      printFilesToText
  button_selectDirectoryToFiles.onClick = proc(event: ClickEvent) =
    var dialog = SelectDirectoryDialog()
    dialog.title = "Select directory containing files that are to be encoded."
    dialog.run()
    if dialog.selectedDirectory == "":
      textArea.addLine("No directory selected.")
    else:
      getFilesFromDir
      saveOutputFiles
  window.show()
  app.run()

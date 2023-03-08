import std/sequtils
import std/strutils
import std/os

import csvtools
import uing

from uing/rawui import nil

if paramCount() < 1:
  stderr.write("Please enter a CSV file to open.\n")

  quit QuitFailure

var 
  filename = paramStr(1)
  rows = csvRows(filename).toSeq()
  autoSave: bool

proc saveFile(file: string = filename) =
  var writeStr: string

  for csvRow in rows:
    writestr.add csvRow.join(",")
    writeStr.add '\n'

  file.writeFile(writeStr)

proc modelNumColumns(mh: ptr TableModelHandler, m: ptr rawui.TableModel): cint {.cdecl.} = cint len(rows[0])
proc modelNumRows(mh: ptr TableModelHandler, m: ptr rawui.TableModel): cint {.cdecl.} = cint len(rows) - 1
proc modelColumnType(mh: ptr TableModelHandler, m: ptr rawui.TableModel, col: cint): TableValueType {.cdecl.} = TableValueTypeString

proc modelCellValue(mh: ptr TableModelHandler, m: ptr rawui.TableModel, row, col: cint): ptr rawui.TableValue {.cdecl.} =
  if col == 0:
    return newTableValue($(row+1)).impl

  for idx, val in rows:
    if idx < 1: continue
    
    # row 0 in `rows` are the headers
    if idx == row + 1:
      # col 0 is the Row column
      return newTableValue(val[col - 1]).impl

proc modelSetCellValue(mh: ptr TableModelHandler, m: ptr rawui.TableModel, row, col: cint, val: ptr rawui.TableValue) {.cdecl.} =
  # col 0 is the "Row" column
  # row 0 in `rows` are the headers
  rows[row + 1][col - 1] = $rawui.tableValueString(val)

  if autoSave:
    saveFile()

proc main =
  var 
    window: Window
    table: Table

  let fileMenu = newMenu("File")

  fileMenu.addItem("Save") do (_: MenuItem, win: Window):
    saveFile()

  fileMenu.addCheckItem("Enable AutoSave") do (item: MenuItem, _: Window):
    autoSave = item.checked

  fileMenu.addSeparator()

  fileMenu.addItem("Save As") do (_: MenuItem, win: Window):
    saveFile(win.saveFile())

  fileMenu.addQuitItem() do () -> bool:
    window.destroy()
    return true

  let editMenu = newMenu("Edit")

  editMenu.addItem("Select All") do (m: MenuItem, win: Window):
    table.selection = (0 .. len(rows)-1).toSeq()

  window = newWindow("", 800, 600, true)
  window.margined = true
  window.title = filename.extractFilename()

  let box = newHorizontalBox(true)
  window.child = box

  # --- table

  var handler: TableModelHandler
  handler.numRows = modelNumRows
  handler.numColumns = modelNumColumns
  handler.columnType = modelColumnType
  handler.cellValue = modelCellValue
  handler.setCellValue = modelSetCellValue

  var model = newTableModel(addr handler)

  var params: TableParams
  params.model = model.impl
  params.rowBackgroundColorModelColumn = -1

  table = newTable(addr params)
  table.selectionMode = TableSelectionModeZeroOrMany

  table.addTextColumn("Row", 0, TableModelColumnNeverEditable)

  for idx, header in rows[0]:
    table.addTextColumn(header, idx + 1, TableModelColumnAlwaysEditable)

  box.add table, true

  show window
  mainLoop()

init()
main()

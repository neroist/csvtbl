import std/sequtils
import std/os

import csvtools
import uing

from uing/rawui import nil

if paramCount() < 1:
  stderr.write("Please enter a CSV file to open.\n")

  quit QuitFailure

var filename = paramStr(1)

proc modelNumColumns(mh: ptr TableModelHandler, m: ptr rawui.TableModel): cint {.cdecl.} = cint len(csvRows(filename).toSeq()[0])
proc modelNumRows(mh: ptr TableModelHandler, m: ptr rawui.TableModel): cint {.cdecl.} = cint len(csvRows(filename).toSeq()) - 1
proc modelColumnType(mh: ptr TableModelHandler, m: ptr rawui.TableModel, col: cint): TableValueType {.cdecl.} = TableValueTypeString

proc modelCellValue(mh: ptr TableModelHandler, m: ptr rawui.TableModel, row, col: cint): ptr rawui.TableValue {.cdecl.} =
  if col == 0:
    return newTableValue($(row+1)).impl

  for idx, val in csvRows(filename).toSeq():
    if idx < 1: continue
    
    if idx == row + 1:
      return newTableValue(val[col - 1]).impl

proc modelSetCellValue(mh: ptr TableModelHandler, m: ptr rawui.TableModel, row, col: cint, val: ptr rawui.TableValue) {.cdecl.} =
  discard # For now...

proc main =
  var window: Window

  let fileMenu = newMenu("File")
  fileMenu.addItem("Open") do (_: MenuItem, win: Window):
    filename = win.openFile()
    win.title = filename

  fileMenu.addQuitItem() do () -> bool: 
    return true

  window = newWindow("", 800, 600, true)
  window.margined = true
  window.title = filename

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

  let table = newTable(addr params)
  table.selectionMode = TableSelectionModeZeroOrMany

  table.addTextColumn("Row", 0, TableModelColumnNeverEditable)

  for idx, header in csvRows(filename).toSeq()[0]:
    table.addTextColumn(header, idx + 1, TableModelColumnNeverEditable)

  box.add table, true

  show window
  mainLoop()

init()
main()

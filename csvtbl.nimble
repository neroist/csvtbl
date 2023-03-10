# Package

version       = "0.1.0"
author        = "Jasmine"
description   = "GUI CSV file reader"
license       = "GPL-2.0-or-later"
srcDir        = "src"
bin           = @["csvtbl"]


# Dependencies

requires "nim >= 1.6.0"
requires "csvtools == 0.2.1"
requires "uing"
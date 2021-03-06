import macros, terminal
from strutils import normalize, parseBool, strip

from configfile import getConfigValue
from ../types import Options

proc isColorEnabled* (): bool =
  let useColor = getConfigValue("user", "terminal_colors")
  result = useColor == "" or useColor.parseBool

template prettyPrint* (color: ForegroundColor, body: typed) =
  if isColorEnabled():
    stdout.setForegroundColor(color)
  body
  resetAttributes()

proc printImpl (icon, msg: string, color: ForegroundColor) =
  prettyPrint color:
    stdout.write(icon)
  stdout.write(msg)

proc print* (msg: string) =
  ## Print a success message with green text.
  printImpl("\n✓ ", msg, fgGreen)
  echo "\n"

proc fail* (msg: string) {.noReturn.} =
  ## Print a failure message with red text, then quit with error code 1.
  printImpl("\n✗ ", msg, fgRed)
  echo "\n"
  quit 1

proc failSoft* (msg: string) =
  ## Print a failure message with red text.
  printImpl("\n✗ ", msg, fgRed)

proc prompt* (msg: string): bool =
  ## Ask the user for confirmation, where "y" and "yes" result in a ``true``
  ## return value, and anything else results in a ``false`` return value.
  printImpl("\n⁉  ", msg & "\n" & "  Do you want to continue? [y/N]", fgBlue)
  let response = stdin.readLine.normalize
  result = response == "y" or response == "yes"

proc promptResponse* (msg: string): string =
  ## Prompt the user to enter a value which is then returned as a string.
  printImpl("\n⁉  ", msg, fgGreen)
  echo "\n"
  result = stdin.readLine.strip

template require* (args: seq[string], req: int, msg: string) =
  ## Check that the number of arguments meets a required minimum,
  ## printing a failure message and quitting if it does not.
  if args.len < req: fail msg

macro get* (opts: Options; shortName, longName: string; T: typedesc = string): untyped =
  let typeNode = getTypeImpl(T)
  let returnType = ($typeNode[1]).normalize
  doAssert returnType in ["string", "int", "bool"]

  let rawValue = genSym(nskLet, "rawValue")
  result = quote do:
    block:
      let (`rawValue`, present) =
        if `shortName` != "" and `shortName` in `opts`: (`opts`[`shortName`], true)
        elif `longName` in `opts`: (`opts`[`longName`], true)
        else: ("", false)

      when `T` is bool:
        present and (`rawValue` == "" or `rawValue`.parseBool)
      elif `T` is string: `rawValue`
      elif `T` is int: `rawValue`.parseInt

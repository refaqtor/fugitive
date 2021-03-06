include ../base

from sequtils import mapIt

const
  usageMessage = """
  Usage: fugitive scrap <...files> [--all|-a]

  Discard local changes to the specified files, or to all files if the `all`
  (or `-a`) flag is provided. This provides a unified interface for the git
  commands `git checkout -- <...files>` and `git reset --hard`.

  Note: be careful as this action can be difficult to reverse.

  Examples:

    fugitive scrap src/foo.nim src/bar.nim
  """

proc scrap* (args: Arguments, opts: Options) =
  if opts.get("h", "help", bool):
    echo "\n" & usageMessage
    quit 0

  if not isGitRepo(): fail errNotRepo

  if opts.get("a", "all", bool):
    match execCmdEx "git reset --hard":
      (_, 0): print "All local changes discarded"
      (@res, _): fail res
    quit 0

  args.require(1, "File names required.")

  match execCmdEx "git checkout -- " & args.mapIt(&"'{it}'").join(" "):
    (_, 0): print "Local changes to files discarded"
    (@res, _): fail res

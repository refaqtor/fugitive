import os
import strutils

import colorize

const
  CONFIG_PATH* = getConfigDir() / "fugitive.ini"

# error messages

const
  NOT_REPO* = "Must be run in a git repository."
  NO_NAME* = "You must provide a username."

# usage strings

const
  PROJECT = "fugitive".fgYellow
  USAGE = "Usage".bold
  COMMANDS = "Commands".bold
  OPTIONS = "Options".bold
  HELP* = """

  $usage: $project [command] [...args] [...options]

  $commands:
    age       <username>           Display the age of the profile for <username>
    alias     [name [--remove|-r]] [expansion]
                                   List, add, or remove git aliases
    clone     <...repos>           Alias for `fugitive mirror`
    install   [--override|-o] [--force|-y]
                                   Alias various fugitive commands as git subcommands
    lock      <...files>           Prevent changes to the specified files from being tracked
    mirror    <...repos>           Wrapper around `git clone` with various URL shorthands
    open      [repo]               Open the current or specified repository's homepage
    repos     <username>           Display the number of public repos for <username>
    summary                        Summarize git repository statistics
    undo      [#] [--hard|-h]      Undo the last commit ( or last # commits )
    uninstall                      Remove git aliases added by `install`
    unlock    <...files>           Resume tracking changes to these locked files
    unstage   <...files>           Remove files from the git stage area

  $options:
    --help, -h       Show this help message
    --version, -v    Output the $project version number
  """ % [
    "project", PROJECT,
    "usage", USAGE,
    "commands", COMMANDS,
    "options", OPTIONS
  ]

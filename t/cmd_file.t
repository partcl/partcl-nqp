# Copyright (C) 2006-2007, The Parrot Foundation.

source lib/test_more.tcl

plan 13

# [file exists]
eval_is {file exists} \
  {wrong # args: should be "file exists name"} \
  {[file exists] too few args} {TODO NQPRX}

eval_is {file exists foo bar} \
  {wrong # args: should be "file exists name"} \
  {[file exists] too many args} {TODO NQPRX}

# this should fail everywhere
is [file exists :%:/bar] 0 {[file exists] does not exist} {TODO NQPRX}

# we really should create a file to test this, but since our "source" line
# above means we have to have that path to this file..
is [file exists lib/test_more.tcl] 1 {[file exists] does exist} {TODO NQPRX}

# [file rootname]
eval_is {file rootname} \
  {wrong # args: should be "file rootname name"} \
  {[file rootname] too few args} {TODO NQPRX}
eval_is {file rootname foo bar} \
  {wrong # args: should be "file rootname name"} \
  {[file rootname] too many args} {TODO NQPRX}

is [file rootname file] file  \
  {[file rootname] filename only} {TODO NQPRX}

is [file rootname file.ext] file \
  {[file rootname] filename with extension} {TODO NQPRX}

is [file rootname f..i.le.ext] f..i.le \
  {[file rootname] filename with dots and extension} {TODO NQPRX}

# [file dirname]
eval_is {file dirname} \
  {wrong # args: should be "file dirname name"} \
  {[file dirname] too few args} {TODO NQPRX}
eval_is {file dirname foo bar} \
  {wrong # args: should be "file dirname name"} \
  {[file dirname] too many args} {TODO NQPRX}

is [file dirname .] .  \
  {[file dirname] dirname dot} {TODO NQPRX}

is [file dirname file.ext] .  \
  {[file dirname] dirname simple file} {TODO NQPRX}

# vim: filetype=tcl:

# Copyright (C) 2006-2007, The Parrot Foundation.

source lib/test_more.tcl
plan 2

eval_is {vwait} \
  {wrong # args: should be "vwait name"} \
  {too few args}

eval_is {vwait foo bar} \
  {wrong # args: should be "vwait name"} \
  {too many args}

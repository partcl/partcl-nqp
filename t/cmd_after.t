# Copyright (C) 2006, The Parrot Foundation.

source lib/test_more.tcl
plan 2

eval_is {after} \
  {wrong # args: should be "after option ?arg arg ...?"} \
  {after - no args}

is [after 10; expr 1] 1 {after - simple delay}

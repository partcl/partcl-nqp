# Copyright (C) 2005-2006, The Parrot Foundation.

source lib/test_more.tcl
plan 5

eval_is {flush} \
  {wrong # args: should be "flush channelId"} \
  {no args}

eval_is {flush the monkeys} \
  {wrong # args: should be "flush channelId"} \
  {too many args}

eval_is {flush toilet} \
  {can not find channel named "toilet"} \
  {invalid channel name}

is [flush stdout] {} out
is [flush stderr] {} err


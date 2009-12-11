# Copyright (C) 2006-2007, The Parrot Foundation.

source lib/test_more.tcl
plan 4

eval_is {fileevent foo} \
  {wrong # args: should be "fileevent channelId event ?script?"} \
  {too few args}

eval_is {fileevent foo bar baz qux} \
  {wrong # args: should be "fileevent channelId event ?script?"} \
  {too many args}

eval_is {fileevent sock1 ontehoeni} \
  {bad event name "ontehoeni": must be readable or writable} \
  {bad channel *and* event}

eval_is {fileevent sock1 readable} \
  {can not find channel named "sock1"} \
  {bad channel}

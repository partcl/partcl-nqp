source lib/test_more.tcl
plan 2

is [lreverse {r a y e}]  {e y a r} {simple lreverse, even # of elements}
is [lreverse {c h i e f}]  {f e i h c} {simple lreverse, odd # of elements}


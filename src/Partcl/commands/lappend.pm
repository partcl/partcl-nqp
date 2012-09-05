#sub lappend(*@args) {
#    if +@args < 1 {
#        error('wrong # args: should be "lappend varName ?value value ...?"');
#    }
#    my $var := @args.shift();
#    my @list;
#    # lappend auto-vivifies
#    try {
#        @list := set($var);
#        CATCH {
#            @list := set($var, pir::new('TclList'));
#        }
#    }
#    @list := @list.getList();
#
#    for @args -> $elem {
#        @list.push($elem);
#    }
#    return set($var,@list);
#}
#
## vim: expandtab shiftwidth=4 ft=perl6:

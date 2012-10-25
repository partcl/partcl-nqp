method lappend(*@args) {
    if +@args < 1 {
        self.error('wrong # args: should be "lappend varName ?value value ...?"');
    }
    my $var := @args.shift();
    my @list;
    # lappend auto-vivifies
    try {
        @list := set($var);
        CATCH {
            @list := set($var, pir::new__Ps('TclList'));
        }
    }
    @list := Iternals.getList(@list);

    for @args -> $elem {
        @list.push($elem);
    }
    return set($var,@list);
}

# vim: expandtab shiftwidth=4 ft=perl6:

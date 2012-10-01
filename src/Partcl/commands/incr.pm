method incr (*@args) {
    if +@args < 1 || +@args > 2 {
        error('wrong # args: should be "incr varName ?increment?"');
    }

    my $var := @args[0];
    my $val := @args[1];

    # incr auto-vivifies
    try {
        set($var);
        CATCH {
            set($var,0);
        }
    }
    return set($var, pir::add__Iii(set($var), $val // 1));
}

# vim: expandtab shiftwidth=4 ft=perl6:

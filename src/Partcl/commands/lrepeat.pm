sub lrepeat(*@args) is export {
    if +@args < 2  {
        error('wrong # args: should be "lrepeat positiveCount value ?value ...?"');
    }
    my $count := @args.shift.getInteger();
    if $count < 1 {
        error('must have a count of at least 1');
    }
    my @result := pir::new__Ps('TclList');
    while $count {
        for @args -> $elem {
            @result.push($elem);
        }
        $count--;
    }
    return @result;
}

# vim: expandtab shiftwidth=4 ft=perl6:

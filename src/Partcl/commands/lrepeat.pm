our sub lrepeat(*@args) {
    if +@args < 2  {
        error('wrong # args: should be "lrepeat positiveCount value ?value ...?"');
    }
    my $count := @args.shift.getInteger();
    if $count < 1 {
        error('must have a count of at least 1');
    }
    my @result := pir::new('TclList');
    while $count {
        for @args -> $elem {
            @result.push($elem);
        }
        $count--;
    }
    return @result;
}

# vim: filetype=perl6:
